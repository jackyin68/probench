#!/usr/bin/env bash

rm *.gem
gem uninstall probench

gem build probench.gemspec

gem install ./*.gem