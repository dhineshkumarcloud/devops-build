#!/bin/bash
docker pull react-app-prod
docker stop react-app || true
docker rm react-app || true
docker run -d -p 80:80 --name react-app react-app-prod