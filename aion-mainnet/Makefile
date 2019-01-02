#!/bin/bash

SHELL := /bin/bash 


deploy:
	rm deploy.zip || zip -r deploy.zip . &&  eb use ${ENV} && eb deploy ${ENV}
