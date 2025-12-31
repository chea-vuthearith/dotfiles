#!/usr/bin/env bash

rm -rf ~/.local/share/Trash/*
nix flake update --flake ~/dotfiles/nix
nsw --upgrade
