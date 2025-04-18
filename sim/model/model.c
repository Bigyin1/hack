#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef N
  #define N 3
#else
  #if N != 3
    #error "Tensors with Dim != 3 are currently not supported"
  #endif
#endif

int get_total_size(int size[N]){
    int total = 0;
    for (int i = 0; i < N; i++)
        total += size[i];
    return total;
}

void add_bias(int* input, int* output, int size[N], int bias){
    for (int i = 0; i < get_total_size(size); i++)
        output[i] = input[i] + bias;
}

void scale_shift(int* input, int* output, int size[N], int scale, int shift){
    for (int i = 0; i < get_total_size(size); i++)
        output[i] = (input[i] * scale) >> shift;
}

void clamp(int* input, int* output, int size[N]){
    for (int i = 0; i < get_total_size(size); i++)
        output[i] = input[i] > 127          ?
                        127                 :
                        input[i] < -128     ?
                            -128            :
                            input[i]        ;
}

void convolve_2d(int* matrix_1, int* matrix_2, int* matrix_3, int size_1[2], int size_2[2], int size_3[2]){
  for (int i3 = 0; i3 < size_3[0]; i3++){     // Rows of matrix_3
    for (int j3 = 0; j3 < size_3[1]; j3++){   // Columns of matrix_3
      int partial_sum = 0;
      for (int i2 = 0; i2 < size_2[0]; i2++){
        for (int j2 = 0; j2 < size_2[1]; j2++){
          int row1 = i3 + i2;
          int col1 = j3 + j2;
          int row2 = i2;
          int col2 = j2;
          int offs_1 = row1 * size_1[1] + col1;
          int offs_2 = row2 * size_2[1] + col2;
          partial_sum += matrix_1[offs_1] * matrix_2[offs_2];
        }
        matrix_3[i3 * size_3[1] + j3] = partial_sum;
      }
    }
  }
}

void convolve(int* matrix_1, int* matrix_2, int* matrix_3, int size_1[N], int size_2[N], int size_3[N]){
  int *m1, *m2, *m3;
  for (int i = 0; i < size_1[2]; i++){
    m1 = &(matrix_1[size_1[0] * size_1[1] * i]);
    for (int j = 0; j < size_2[2]; j++){
      m2 = &(matrix_2[size_2[0] * size_2[1] * j]);
      m3 = &(matrix_3[size_3[0] * size_3[1] * size_2[2] * i + size_3[0] * size_3[1] * j]);
      convolve_2d(m1, m2, m3, size_1, size_2, size_3);
    }
  }
}

void relu(int* input, int* output, int size[N]){
    for (int i = 0; i < get_total_size(size); i++)
        output[i] = input[i] > 0 ? input[i] : 0;
}

void npu_model( int* matrix_1, int* matrix_2, int* matrix_3,
                int size_1[N], int size_2[N], int size_3[N],
                int zp_1, int zp_2, int zp_3,
                int bias, int scale, int shift){
    int* m_1 = (int*)malloc(get_total_size(size_1) * sizeof(int));
    int* m_2 = (int*)malloc(get_total_size(size_2) * sizeof(int));
    int* m_3 = (int*)malloc(get_total_size(size_3) * sizeof(int));
    if (m_1 == NULL || m_2 == NULL || m_3 == NULL)
        printf("Malloc error");
    add_bias(matrix_1, m_1, size_1, zp_1);
    add_bias(matrix_2, m_2, size_2, zp_2);
    convolve(m_1, m_2, m_3, size_1, size_2, size_3);
    add_bias(m_3, m_3, size_3, bias);
    scale_shift(m_3, m_3, size_3, scale, shift);
    relu(m_3, m_3, size_3);
    add_bias(m_3, m_3, size_3, zp_3);
    clamp(m_3, matrix_3, size_3);
    free(m_1);
    free(m_2);
    free(m_3);
}
