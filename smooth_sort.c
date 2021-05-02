#include<stdio.h>
#include<stdlib.h>
#include<time.h>

extern void smooth_sort(__int64_t *, __uint64_t) __attribute__((cdecl));

int main(int argc, char *argv[])
{
        FILE *fp;
        __int64_t *array;
        __uint64_t len, i;
        clock_t start, end;
        int status = 1;

        if (argc == 1) {
                fp = stdin;
        } else {
                if (!(fp = fopen(argv[1], "r")))
                        return -1;
        }

        if (fscanf(fp, "%lu", &len) <= 0 ||\
                !(array = calloc(len, sizeof(__int64_t)))) {
                status = -2;
        } else {
                for (i = 0; i < len; i++) {
                        if ((status = fscanf(fp, "%ld", array + i)) > 0)
                                continue;
                        if (status == EOF) {
                                len = i;
                                status = 0;
                        } else {
                                free(array);
                                status = -3;
                        }
                        break;
                }
        }

        if (fp != stdin)
                fclose(fp);
        if (status < 0) {
                return status;
        } else {
                status = 1 - status;
        }

        start = clock();
        smooth_sort(array, len);
        end = clock();

        for (i = 0; i < len; i++) {
                printf("%ld", array[i]);
                if ((i + 1) % 10)
                        putchar(9);
                else
                        putchar(10);
        }
        if (i && i % 10)
                putchar(10);
        printf("Elapsed time: %.4fs\n", (float)(end - start) / CLOCKS_PER_SEC);

        free(array);
        return status;
}
