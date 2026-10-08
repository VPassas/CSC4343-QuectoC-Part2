set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build

bison -Wall -Werror -d \
    --report=state \
    --report-file=build/parser.output \
    -o build/parser.tab.c parser.y

flex -o build/lex.yy.c scanner.l

gcc -std=c11 -Wall -Wextra -Werror -I build \
    build/parser.tab.c build/lex.yy.c main.c \
    -o build/quectoc-parser