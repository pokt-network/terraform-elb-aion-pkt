#!/bin/bash

SHELL := /bin/bash 


deploy:
	rm deploy.zip | zip -r deploy.zip . && eb deploy $(ENV)
