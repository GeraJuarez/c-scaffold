#!/bin/bash

# Scafold for a basic c program
# TODO: Add a program with a module. The module itself has
# to have a test and the program as well.
# TODO: bash c-scafold <program-name> <module-name>
# TODO: Find a good image for building the project
# TODO: Separate functions one to create modules and the other to create the project.
# both can be independent so module scafold can be reused without anyproblem in all the
# projects.
# TODO: When a module is created you have to verify if the test library is there. Also
# you have to display the information that user have to add you its building script.
# TODO: Add help command
# TODO: Refactor everything into functions
# TODO: Read the article about best practices in bash and implement it here.
# TODO: Add directory structure (src, test, dist)
# TODO: Change to use cammel case standard 
# TODO: Add function to add another module, similar to hugo
# TODO: Add ifdef clausulles 
# TODO: modify utest library to use errorMessage variable to print messages

PROJECT_NAME=$1
MODULE_NAME=$2

CURRENT_DIRECTORY=$(pwd)

if [[ -z "${PROJECT_NAME}" ]]; then
  echo "Please add the name of the project"
  exit
fi

if [[ -z "${MODULE_NAME}" ]]; then
  echo "Please add the name of the module"
  exit
fi

if [[ -d "${CURRENT_DIRECTORY}/${PROJECT_NAME}" ]]; then
  echo "The folder exists. Choose another name"
  exit
fi

mkdir "${CURRENT_DIRECTORY}/${PROJECT_NAME}"
mkdir "${CURRENT_DIRECTORY}/${PROJECT_NAME}/lib"

cd "${CURRENT_DIRECTORY}/${PROJECT_NAME}"

touch "${MODULE_NAME}".c
touch "${MODULE_NAME}".h
touch minunit.h
touch maintest.tcl
touch ${MODULE_NAME}_test.c
touch Makefile
touch main.c
touch README.md 

echo "# ${PROJECT_NAME}
" > README.md

echo "#include <stdlib.h>
#include <stdio.h>
#include \"${MODULE_NAME}.h\"
" > ${MODULE_NAME}.c

echo "#include <stdlib.h>
#include <stdio.h>
#include \"${MODULE_NAME}.h\"

/* Add function signatures here */

int main() {
  /* Start your code here */
  printf(\"Hello from main\\n\");
  return 0;
}" > main.c

##integration test
echo "#!/usr/bin/expect -f
# For colors
proc capability cap {expr {![catch {exec tput -S << \$cap}]}}
proc colorterm {} {expr {[capability setaf] && [capability setab]}}
proc tput args {exec tput -S << \$args >/dev/tty}
array set color {black 0 red 1 green 2 yellow 3 blue 4 magenta 5 cyan 6 white 7}
proc foreground x {exec tput -S << \"setaf $::color(\$x)\" > /dev/tty}
proc background x {exec tput -S << \"setab $::color(\$x)\" > /dev/tty}
proc reset {} {exec tput sgr0 > /dev/tty}


#Put your test case here
eval spawn [lrange \$argv 0 end]

expect \"Hello from main\" {foreground green; puts \"PASSED\";reset} default {foreground red;puts \"FAILED\";reset}

" > maintest.tcl

chmod 755 maintest.tcl

{
  echo "LIB := \$(shell find ./lib -name '*.o')"

  echo "clean:"
  echo -e "\trm *.out *.o *.exe || exit 0"
  echo ""

  echo "${MODULE_NAME}test: clean"
  echo -e "\tgcc -c ${MODULE_NAME}.c"
  echo -e "\tgcc -c ${MODULE_NAME}_test.c"
  echo -e "\tgcc -o ${MODULE_NAME}test.exe ${MODULE_NAME}.o ${MODULE_NAME}_test.o"
  echo -e "\t./${MODULE_NAME}test.exe"
  echo ""

  echo -e "test: ${MODULE_NAME}test"
  echo ""

  echo "${MODULE_NAME}: clean"
  echo -e "\tgcc -c ${MODULE_NAME}.c"
  echo -e "\tgcc -c main.c"
  echo -e "\tgcc -o ${MODULE_NAME}.exe ${MODULE_NAME}.o main.o \$(LIB)"
  echo ""

  echo -e "maintest: ${MODULE_NAME}"
  echo -e "\t./maintest.tcl ./${MODULE_NAME}.exe"
  echo ""

  echo  "run: ${MODULE_NAME}"
  echo -e "\t./${MODULE_NAME}.exe"
  echo ""

} > Makefile

{
  echo '/* file: minunit.h */'
  echo '#define muAssert(message, test) do { if (!(test)) return message; } while (0)'
  echo '#define muRunTest(test) do { char *message = test(); testsRun++; \'
  echo 'if (message) return message; } while (0)'
  echo 'extern int testsRun;'
} >  minunit.h

{
  echo '#include <stdio.h>'
  echo '#include "minunit.h"'
  echo "#include \"${MODULE_NAME}.h\""
  echo ""
  echo '#define KNRM  "\x1B[0m"'
  echo '#define KRED  "\x1B[31m"'
  echo '#define KGRN  "\x1B[32m"'
  echo '#define KYEL  "\x1B[33m"'
  echo '#define KBLU  "\x1B[34m"'
  echo '#define KMAG  "\x1B[35m"'
  echo '#define KCYN  "\x1B[36m"'
  echo '#define KWHT  "\x1B[37m"'
  echo '#define RESET "\033[0m"'
  echo ""
  echo 'int testsRun = 0;'

  echo ""
  echo 'static char * testUnit() {'
  echo '  	muAssert("error, testUnit 1 != 1", 1 == 1);'
  echo '  	return 0;'
  echo '}'

  echo ""
  echo 'static char * allTests() {'
  echo '  	muRunTest(testUnit);'
  echo '  	return 0;'
  echo '}'

  echo ""
  echo 'int main(int argc, char **argv) {'
  echo '	char *result = allTests();'
  echo '  	if (result != 0) {'
  echo '    	printf("-_-_-_-_-_-_-_,------,      o \n");'
  echo '      	printf("_-_-_-_-_-_-_-|   /\\_/\\ \n");'
  echo '      	printf("-_-_-_-_-_-_-~|__( X .X)  +     + \n");'
  echo '      	printf("_-_-_-_-_-_-_- \"\"  \"\" \n");'
  echo '      	printf(KRED "✗ %s \n" RESET, result);';
  echo '	}'
  echo '  	else {'
  echo '      	printf("-_-_-_-_-_-_-_,------,      o \n");'
  echo '      	printf("_-_-_-_-_-_-_-|   /\\_/\\ \n");'
  echo '      	printf("-_-_-_-_-_-_-~|__( ^ .^)  +     + \n");'
  echo '      	printf("_-_-_-_-_-_-_-  \"\"  \"\" \n");'
  echo '      	printf(KGRN " ✓ ALL TESTS PASSED \n" RESET);'
  echo '  	}'
  echo '  	printf("Tests run: %d\n", testsRun);'
  echo '  	return result != 0;'
  echo '}'

} > ${MODULE_NAME}_test.c

echo 'Happy Coding!'
echo ''
tree ${CURRENT_DIRECTORY}/${PROJECT_NAME}
