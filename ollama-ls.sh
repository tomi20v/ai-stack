#!/usr/bin/env bash

ollama ls | awk 'NR==1; NR>1 {print | "sort"}'
