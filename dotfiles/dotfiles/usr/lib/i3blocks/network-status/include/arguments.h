#ifndef ARGUMENTS_H
#define ARGUMENTS_H

struct args {
    struct interface* interfaces;
    double good_level;
    double medium_level;
    char* good_color;
    char* medium_color;
    char* bad_color;
    char* down_color;
};

void parse_arguments(int argc, char** argv, struct args* args);

#endif
