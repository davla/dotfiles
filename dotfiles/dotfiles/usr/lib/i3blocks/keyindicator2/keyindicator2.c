/*
    This file prints activation indicators for Caps Lock and Num Lock. It is
    meant to be used as a command for i3blocks. It outputs text in different
    colors based on Caps Lock and Num Lock status, in pango markup.
*/

/* If both NO_CAPS and NO_NUM are defined, no output will ever be printed. */
#if defined NO_CAPS && defined NO_NUM
    #error Both NO_CAPS and NO_NUM defined
#endif

/* Shorthand to check whether any CLI option should be processed at all. */
#if defined ACTIVE_COLOR && defined CAPS_LABEL && defined INACTIVE_COLOR && defined NUM_LABEL
    #define NO_ARGS
#endif

/*
    Defining macros for whether single CLI options should be processed: if the
    corresponding macro is defined, the CLI option should not exist and raise
    an error.
*/
#ifndef ACTIVE_COLOR
    #define ACTIVE_COLOR_HAS_OPT
#endif
#if ! (defined CAPS_LABEL || defined NO_CAPS)
    #define CAPS_LABEL_HAS_OPT
#endif
#ifndef INACTIVE_COLOR
    #define INACTIVE_COLOR_HAS_OPT
#endif
#if ! (defined NUM_LABEL || defined NO_NUM)
    #define NUM_LABEL_HAS_OPT
#endif

/*
    Setting labels to null when they are disabled. Necessary for the
    *_LABEL_VALUE macros below not to explode.
*/
#ifdef NO_CAPS
    #undef CAPS_LABEL
    #define CAPS_LABEL (NULL)
#endif
#ifdef NO_NUM
    #undef NUM_LABEL
    #define NUM_LABEL (NULL)
#endif

/* Optimizing includes ;-P */
#ifndef NO_ARGS
    #include <getopt.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <X11/Xlib.h>

/* Bit masks for X11 keyboard leds. */
#define CAPS_MASK (0x1)
#define NUM_MASK (0x2)

/* Default color values. */
#define DEFAULT_ACTIVE_COLOR ("#00FF00")
#define DEFAULT_INACTIVE_COLOR ("#666666")

/*

*/
#ifdef ACTIVE_COLOR_HAS_OPT
    #define ACTIVE_COLOR_VALUE (ifnull(getenv("ACTIVE_COLOR"), DEFAULT_ACTIVE_COLOR))
    #define ACTIVE_COLOR_OPT "a:"
    #define ACTIVE_COLOR_LONG_INDEX (0)
#else
    #define ACTIVE_COLOR_VALUE (ACTIVE_COLOR)
    #define ACTIVE_COLOR_OPT ""
    #define ACTIVE_COLOR_LONG_INDEX (-1)
#endif
#ifdef CAPS_LABEL_HAS_OPT
    #define CAPS_LABEL_VALUE (getenv("CAPS_LABEL"))
    #define CAPS_LABEL_OPT "c:"
    #define CAPS_LABEL_LONG_INDEX (ACTIVE_COLOR_LONG_INDEX + 1)
#else
    #define CAPS_LABEL_VALUE (CAPS_LABEL)
    #define CAPS_LABEL_OPT ""
    #define CAPS_LABEL_LONG_INDEX (ACTIVE_COLOR_LONG_INDEX)
#endif
#ifdef INACTIVE_COLOR_HAS_OPT
    #define INACTIVE_COLOR_VALUE (ifnull(getenv("INACTIVE_COLOR"), DEFAULT_INACTIVE_COLOR))
    #define INACTIVE_COLOR_OPT "i:"
    #define INACTIVE_COLOR_LONG_INDEX (CAPS_LABEL_LONG_INDEX + 1)
#else
    #define INACTIVE_COLOR_VALUE (INACTIVE_COLOR)
    #define INACTIVE_COLOR_OPT ""
    #define INACTIVE_COLOR_LONG_INDEX (CAPS_LABEL_LONG_INDEX)
#endif
#ifdef NUM_LABEL_HAS_OPT
    #define NUM_LABEL_VALUE (getenv("NUM_LABEL"))
    #define NUM_LABEL_OPT "n:"
    #define NUM_LABEL_LONG_INDEX (INACTIVE_COLOR_LONG_INDEX + 1)
#else
    #define NUM_LABEL_VALUE (NUM_LABEL)
    #define NUM_LABEL_OPT ""
    #define NUM_LABEL_LONG_INDEX (INACTIVE_COLOR_LONG_INDEX)
#endif

/* getopt string. Contains only the options for undefined macros. */
#define GETOPT_STRING (ACTIVE_COLOR_OPT CAPS_LABEL_OPT INACTIVE_COLOR_OPT NUM_LABEL_OPT)

/* Convenience data structure for CLI arguments. */
struct args {
    char* caps_label;
    char* num_label;
    char* active_color;
    char* inactive_color;
};

#ifndef NO_ARGS
    char* ifnull(char* a, char* b) {
        return a ? a : b;
    }
#endif

void parse_arguments(int argc, char** argv, struct args* args) {
    #ifndef NO_ARGS
        /* Long options definition */
        static struct option long_options[] = {
            #ifdef ACTIVE_COLOR_HAS_OPT
                {"active-color", required_argument, 0, 0},
            #endif
            #ifdef CAPS_LABEL_HAS_OPT
                {"caps-label", required_argument, 0, 0},
            #endif
            #ifdef INACTIVE_COLOR_HAS_OPT
                {"inactive-color", required_argument, 0, 0},
            #endif
            #ifdef NUM_LABEL_HAS_OPT
                {"num-label", required_argument, 0, 0}
            #endif
        };
        int long_opt_index, opt;

        /* This array maps long option indices to the corresponding args fields */
        char** long_opts_to_args[NUM_LABEL_LONG_INDEX + 1];
        #ifdef ACTIVE_COLOR_HAS_OPT
            long_opts_to_args[ACTIVE_COLOR_LONG_INDEX] = &(args->active_color);
        #endif
        #ifdef CAPS_LABEL_HAS_OPT
            long_opts_to_args[CAPS_LABEL_LONG_INDEX] = &(args->caps_label);
        #endif
        #ifdef INACTIVE_COLOR_HAS_OPT
            long_opts_to_args[INACTIVE_COLOR_LONG_INDEX] = &(args->inactive_color);
        #endif
        #ifdef NUM_LABEL_HAS_OPT
            long_opts_to_args[NUM_LABEL_LONG_INDEX] = &(args->num_label);
        #endif
    #else
        if (argc > 1) {
            fprintf(stderr, "No CLI argument accepted!\n");
            exit(EXIT_FAILURE);
        }
    #endif

    /* Checking environment variables and setting defaults */
    args->active_color = ACTIVE_COLOR_VALUE;
    args->caps_label = CAPS_LABEL_VALUE;
    args->inactive_color = INACTIVE_COLOR_VALUE;
    args->num_label = NUM_LABEL_VALUE;

    #ifndef NO_ARGS
        /* Parsing CLI options */
        while ((opt = getopt_long(argc, argv, GETOPT_STRING, long_options,
                &long_opt_index)) != -1) {
            switch (opt) {
                case 0:
                    *(long_opts_to_args[long_opt_index]) = optarg;
                    break;

                #ifdef ACTIVE_COLOR_HAS_OPT
                    case 'a':
                        args->active_color = optarg;
                        break;
                #endif

                #ifdef CAPS_LABEL_HAS_OPT
                    case 'c':
                        args->caps_label = optarg;
                        break;
                #endif

                #ifdef INACTIVE_COLOR_HAS_OPT
                    case 'i':
                        args->inactive_color = optarg;
                        break;
                #endif

                #ifdef NUM_LABEL_HAS_OPT
                    case 'n':
                        args->num_label = optarg;
                        break;
                #endif

                default:
                    /* getopt has already printed an error message */
                    exit(EXIT_FAILURE);
            }
    }
    #endif
}

unsigned long get_leds() {
    XKeyboardState keyboard;
    Display* display = XOpenDisplay(NULL);
    XGetKeyboardControl(display, &keyboard);
    return keyboard.led_mask;
}

void show_indicator(unsigned long led, const char* label,
        const struct args* args) {
    printf("<span color='%s'>%s</span>",
        led ? args->active_color : args->inactive_color, label);
}

int main(int argc, char** argv) {
    unsigned long leds;
    struct args args;

    parse_arguments(argc, argv, &args);
    leds = get_leds();

    #ifndef NO_CAPS
        #ifdef CAPS_LABEL_HAS_OPT
            if (args.caps_label) {
                show_indicator(leds & CAPS_MASK, args.caps_label, &args);
            }
        #else
            show_indicator(leds & CAPS_MASK, args.caps_label, &args);
        #endif
    #endif

    #ifndef NO_NUM
        #ifdef NUM_LABEL_HAS_OPT
            if (args.num_label) {
                show_indicator(leds & NUM_MASK, args.num_label, &args);
            }
        #else
            show_indicator(leds & NUM_MASK, args.num_label, &args);
        #endif
    #endif

    printf("\n");
}
