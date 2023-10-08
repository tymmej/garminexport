FROM python:3.12
RUN apt update && apt install -y python3-dev git build-essential libcurl4-openssl-dev
RUN pip install "git+https://github.com/tymmej/garminexport.git@subfolders#egg=garminexport[impersonate_browser]"
