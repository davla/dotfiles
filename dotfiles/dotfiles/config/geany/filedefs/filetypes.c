# For complete documentation of this file, please see Geany's main documentation

[styling]

# Edit these in the colorscheme .conf file instead

default=default
comment=comment
commentline=comment_line
commentdoc=comment_doc
preprocessorcomment=comment
preprocessorcommentdoc=comment_doc
number=number
word=keyword
word2=keyword_2
string=string_1
stringraw=string
character=character
uuid=other
preprocessor=preprocessor
operator=operator
identifier=identifier
stringeol=string_eol
verbatim=string_2
regex=regex
commentlinedoc=comment_line_doc
commentdockeyword=comment_doc_keyword
commentdockeyworderror=comment_doc_keyword_error
globalclass=class
# """verbatim"""
tripleverbatim=string_2
hashquotedstring=string_2

[keywords]

# all items must be in one line

primary=asm auto break case char const continue default do double else enum extern float for goto if inline int long register restrict return short signed sizeof static struct switch typedef union unsigned void volatile while FALSE false NULL TRUE true

secondary=accept AF_INET AF_UNIX alarm bind calloc close connect execl execlp execle execv execve execvp execvpe exit _exit fclose FD_CLR FD_ISSET FD_SET fd_set FD_SETSIZE FD_ZERO fdopen fflush fgets FILE fopen fork fprintf fputs fread free fscanf fseek fwrite getegid geteuid getgid getpid getppid gets getuid htonl htons INADDR_ANY inet_ntop inet_pton kill listen lseek malloc memset mknod MSG_WAITALL ntohl ntohs open perror pid_t printf pthread_attr_destroy pthread_attr_init pthread_attr_setdetachstate pthread_attr_t pthread_cond_t pthread_condattr_t pthread_cond_broadcast pthread_cond_destroy pthread_cond_init PTHREAD_COND_INITIALIZER pthread_cond_signal pthread_cond_wait pthread_create PTHREAD_CREATE_DETACHED PTHREAD_CREATE_JOINABLE pthread_equal pthread_exit pthread_join pthread_mutexattr_t pthread_mutex_destroy pthread_mutex_init PTHREAD_MUTEX_INITIALIZER pthread_mutex_lock pthread_mutex_t pthread_mutex_trylock pthread_mutex_unlock pthread_self pthread_t puts realloc read recv recvfrom recvmsg s_addr sa_handler sa_sigaction sa_mask sa_flags scanf select sem_destroy sem_getvalue sem_init sem_post sem_t SEM_VALUE_MAX sem_wait sem_trywait send sendmsg sendto setgid setsockopt setuid sigaction sigaddset sigdelset sigemptyset sigfillset singinfo_t sigismember signal sigprocmask sigset_t SIG_DFL SIG_IGN sin_addr sin_family sin_port size_t sleep SOCK_DGRAM SOCK_STREAM sockaddr sockaddr_in socket socklen_t sprintf stat sscanf strcat strcmp strcpy strlen strncat strncpy timeval tv_sec tv_usec uint16_t uint32_t wait write

# these are the Doxygen keywords

docComment=a addindex addtogroup anchor arg attention author authors b brief bug c callergraph callgraph category cite class code cond copybrief copydetails copydoc copyright date def defgroup deprecated details dir dontinclude dot dotfile e else elseif em endcode endcond enddot endhtmlonly endif endinternal endlatexonly endlink endmanonly endmsc endrtfonly endverbatim endxmlonly enum example exception extends file fn headerfile hideinitializer htmlinclude htmlonly if ifnot image implements include includelineno ingroup interface internal invariant latexonly li line link mainpage manonly memberof msc mscfile n name namespace nosubgrouping note overload p package page par paragraph param post pre private privatesection property protected protectedsection protocol public publicsection ref related relatedalso relates relatesalso remark remarks result return returns retval rtfonly sa section see short showinitializer since skip skipline snippet struct subpage subsection subsubsection tableofcontents test throw throws todo tparam typedef union until var verbatim verbinclude version warning weakgroup xmlonly xrefitem

[lexer_properties]

styling.within.preprocessor=1
lexer.cpp.track.preprocessor=0
preprocessor.symbol.$(file.patterns.cpp)=#
preprocessor.start.$(file.patterns.cpp)=if ifdef ifndef
preprocessor.middle.$(file.patterns.cpp)=else elif
preprocessor.end.$(file.patterns.cpp)=endif

[settings]

# default extension used when saving files

extension=c

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file

comment_single=//

# multiline comments

comment_open=/*
comment_close=*/

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments

comment_use_indent=true

# context action command (please see Geany's main documentation for details)

context_action_cmd=

[indentation]
#width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
#type=1

[build_settings]

# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)

compiler=gcc -Wall -c "%f"
linker=gcc -Wall -o "%e" "%f"
run_cmd="./%e"


