<?php spl_autoload_register(function($className){require_once str_replace('\\',DIRECTORY_SEPARATOR,$className).'.php';});
