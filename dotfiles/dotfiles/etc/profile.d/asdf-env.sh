#!/usr/bin/env sh

# {{@@ header() @@}}
#
# This file contains the environment variables used to configure asdf

{%@@ for name, value in asdf_env_var.items() -@@%}
    export {{@@ name | upper @@}}={{@@ value @@}}
{%@@ endfor @@%}
