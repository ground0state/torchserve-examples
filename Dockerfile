FROM alpine/git AS build

WORKDIR /work

COPY . .

RUN git clone https://github.com/pytorch/serve.git && \
    wget https://download.pytorch.org/models/densenet161-8d451a50.pth && \
    mkdir model_store

# FROM pytorch/torchserve:0.1.1-cpu
FROM pytorch/torchserve:0.1.1-cuda10.1-cudnn7-runtime

COPY --from=build /work /home/model-server

WORKDIR /home/model-server

RUN torch-model-archiver --model-name densenet161 \
    --version 1.0 --model-file serve/examples/image_classifier/densenet_161/model.py \
    --serialized-file densenet161-8d451a50.pth \
    --export-path /home/model-server/model-store \
    --extra-files serve/examples/image_classifier/index_to_name.json \
    --handler image_classifier

CMD ["torchserve", \
    "--start",\
    "--models", "densenet161=densenet161.mar",\
    "--ts-config", "config.properties"]
