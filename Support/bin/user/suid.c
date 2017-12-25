#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include <errno.h>

/*

This file emulates the suid bit,
which is ignored for some file
types, provided that this file
runs as root

It sets the uid of the process
to that of the owner of the file
passed as first argument, much
like suid.

If the file requires aruments,
they can be written as usual
after the filename

*/

int main(int argc, char** argv) {

	FILE* stdout;
	char* path;
	struct stat data;
	char* which;

	/* Building which command */
	/* strlen("which ") + 1 == 7 */

	if (!(which = malloc((7 + strlen(argv[1])) * sizeof(char)))) {
		perror("Error while allocating dynamic string for which command\n");
		return 1;
	}
	strcpy(which, "which ");
	strcat(which, argv[1]);

	/* Executing which command */

	if (!(stdout = popen(which, "r"))) {
		perror("Error while executing which\n");
		return 1;
	}

	/*

	If nothing is returned by which, assuming
	argv[1] to be a valid path

	*/

	if (fscanf(stdout, "%ms", &path) == EOF) {
		free(path);
		path = argv[1];
	}

	/* Getting file's owner by using of stat */

	if (stat(path, &data)) {
		perror("Error while getting file's owner\n");
		return 1;
	}

	/* Free & close */

	free(which);
	if (path != argv[1])
		free(path);
	pclose(stdout);

	/*

	Setting process' uid to owner uid
	of passed file and executing it

	*/

	setuid(data.st_uid);
	execvp(argv[1], argv + 2);

	return 0;
}
