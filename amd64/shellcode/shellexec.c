#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <shellcode_file>\n", argv[0]);
        return 1;
    }

    const char *filename = argv[1];
    FILE *file = fopen(filename, "rb");
    unsigned char *shellcode;

    
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    int shellcode_size = 1024;

    // Read the shellcode
    shellcode = (unsigned char *)malloc(shellcode_size);
    if (!shellcode) {
        perror("Error allocating memory for shellcode");
        fclose(file);
        return 1;
    }
    unsigned char code[1024];
    fread(shellcode, 1, shellcode_size, file);
    fclose(file);
    memcpy(code, shellcode, shellcode_size);

    printf("Executing shellcode...\n");
    (*(void (*)()) code)();
    printf("Shellcode executed.\n");

    // Free the allocated memory
    free(shellcode);

    return 0;
}
