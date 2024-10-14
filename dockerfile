FROM nvcr.io/nvidia/pytorch:23.10-py3

# Upgrade pip
RUN python -m pip install --upgrade pip
# Install necessary dependencies
RUN apt-get update && apt-get install -y git curl
# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# Source the Rust environment for the current shell
RUN /bin/bash -c "source $HOME/.cargo/env"
# Install Python libraries: transformers and sentencepiece
RUN pip install transformers sentencepiece
# Set up workspace
RUN mkdir -p /workspace
WORKDIR /workspace
# Expose port for use
EXPOSE 8000:8000