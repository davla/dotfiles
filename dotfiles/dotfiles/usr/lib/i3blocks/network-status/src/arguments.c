#include <getopt.h>
#include <stdio.h>

#include "arguments.h"
#include "common.h"
#include "interface.h"

void interfaces_add_field(struct interface** ifs, char* value,
        int (*has_field)(struct interface*),
        void (*set_field)(struct interface*, const char*)) {
    struct interface* this = *ifs;

    while (this && has_field(this)) {
        ifs = &this->next;
        this = *ifs;
    }

    if (!this) {
        this = interface_new();
        *ifs = this;
    }

    set_field(this, value);
}

void parse_arguments(int argc, char** argv, struct args* args) {
    struct interface* ifs;

    /* Long options definition */
    static struct option long_options[] = {
        {"bad-color", required_argument, NULL, 'B'},
        {"down-color", required_argument, NULL, 'D'},
        {"good-color", required_argument, NULL, 'G'},
        {"medium-color", required_argument, NULL, 'M'},
        {"good-level", required_argument, NULL, 'g'},
        {"help", no_argument, NULL, 'h'},
        {"interface", required_argument, NULL, 'i'},
        {"label", required_argument, NULL, 'l'},
        {"medium-level", required_argument, NULL, 'm'},
        {0, 0, 0}
    };
    int long_opt_index, opt;

    args->interfaces = NULL;
    args->good_level = 80.0;
    args->medium_level = 40.0;
    args->good_color = "#00FF00";
    args->medium_color = "#FFFF00";
    args->bad_color = "#FF0000";
    args->down_color = "#666666";

    while ((opt = getopt_long(argc, argv, "B:D:G:M:g:hi:l:m:", long_options,
            &long_opt_index)) != -1) {
        switch (opt) {
            case 'B':
                args->bad_color = optarg;
                break;

            case 'D':
                args->down_color = optarg;
                break;

            case 'G':
                args->good_color = optarg;
                break;

            case 'M':
                args->medium_color = optarg;
                break;

            case 'g':
                args->good_level = atof(optarg);
                break;

            case 'h':
                // display help
                break;

            case 'i':
                interfaces_add_field(&args->interfaces, optarg,
                    interface_has_name, interface_set_name);
                break;

            case 'l':
                interfaces_add_field(&args->interfaces, optarg,
                    interface_has_label, interface_set_label);
                break;

            case 'm':
                args->medium_level = atof(optarg);
                break;

            case '?':
            default:
                /* getopt has already printed an error message */
                exit(EXIT_FAILURE);
        }
    }

    for (ifs = args->interfaces; ifs; ifs = ifs->next) {
        interface_infer(ifs);
        interface_validate(ifs);
    }
}
