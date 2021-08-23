variable "IMAGE_NAME" {
    default = "dcagatay/java-node-bamboo-agent"
}

variable "IMAGE_TAG" {
    default = "latest"
}

group "default" {
    targets = [ "8.0.0" ]
}

target "main" {
    context = "."
    platforms = [ "linux/amd64" ]
    dockerfile = "Dockerfile"
    tags = [
        "docker.io/${IMAGE_NAME}:${IMAGE_TAG}"
    ]
}
target "8.0.0" {
    inherits = ["main"]
    dockerfile = "Dockerfile"
    tags = [
        "docker.io/${IMAGE_NAME}:latest",
        "docker.io/${IMAGE_NAME}:8.0.0"
    ]
}
