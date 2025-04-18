//---------------------------------------------------------
// Class: npu_model
//---------------------------------------------------------

// NPU model

class npu_model extends uvm_object;

    `uvm_object_utils(npu_model)
    `uvm_object_new


    //---------------------------------------------------------
    // Function: get_total_size
    //---------------------------------------------------------

    // Method to compute total size of a tensor

    virtual function int get_total_size(int size[3]);
        int total = 1;
        foreach (size[i]) begin
            total *= size[i];
        end
        return total;
    endfunction

    //---------------------------------------------------------
    // Function: add_bias
    //---------------------------------------------------------

    // Add bias to input tensor

    virtual function void add_bias(
        input  int in  [ ],
        output int out [ ],
        input  int size[3],
        input  int bias
    );
        int total_size = get_total_size(size);
        out = new[total_size];
        for (int i = 0; i < total_size; i++) begin
            out[i] = $signed(in[i]) + $signed(bias);
        end
    endfunction


    //---------------------------------------------------------
    // Function: scale_shift
    //---------------------------------------------------------

    // Scale and shift input tensor

    virtual function void scale_shift(
        input  int in  [ ],
        output int out [ ],
        input  int size[3],
        input  int scale,
        input  int shift
    );
        int total_size = get_total_size(size);
        out = new[total_size];
        for (int i = 0; i < total_size; i++) begin
            longint r = $signed(in[i]) * $signed(scale);
            out[i] = $signed(r) >>> (31 + shift);
        end
    endfunction


    //---------------------------------------------------------
    // Function: clamp
    //---------------------------------------------------------

    // Clamp input tensor values to [-128, 127]
    virtual function void clamp(
        input  int in  [ ],
        output int out [ ],
        input  int size[3]
    );
        int total_size = get_total_size(size);
        out = new[total_size];
        for (int i = 0; i < total_size; i++) begin
            out[i] = in[i] >  127 ?  127 :
                     in[i] < -128 ? -128 :
                     $signed(in[i]);
        end
    endfunction

    //---------------------------------------------------------
    // Function: relu
    //---------------------------------------------------------

    // Apply ReLU activation

    virtual function void relu(
        input  int in  [ ],
        output int out [ ],
        input  int size[3]
    );
        int total_size = get_total_size(size);
        out = new[total_size];
        for (int i = 0; i < total_size; i++) begin
            out[i] = $signed(in[i]) > 0 ? $signed(in[i]) : 0;
        end
    endfunction


    //---------------------------------------------------------
    // Function: convolve_2d
    //---------------------------------------------------------

    // 2D Convolution

    virtual function void convolve_2d(
        input  int matrix_1[ ],
        input  int matrix_2[ ],
        output int matrix_3[ ],
        input  int size_1  [3],
        input  int size_2  [3],
        input  int size_3  [3]
    );
        matrix_3 = new[size_3[0] * size_3[1]];
        for (int i3 = 0; i3 < size_3[0]; i3++) begin
            for (int j3 = 0; j3 < size_3[1]; j3++) begin
                int partial_sum = $signed(0);
                for (int i2 = 0; i2 < size_2[0]; i2++) begin
                    for (int j2 = 0; j2 < size_2[1]; j2++) begin
                        int row1 = i3 + i2;
                        int col1 = j3 + j2;
                        int row2 = i2;
                        int col2 = j2;
                        int offs_1 = row1 * size_1[1] + col1;
                        int offs_2 = row2 * size_2[1] + col2;
                        partial_sum += $signed(matrix_1[offs_1]) * $signed(matrix_2[offs_2]);
                    end
                end
                matrix_3[i3 * size_3[1] + j3] = $signed(partial_sum);
            end
        end
    endfunction

    //---------------------------------------------------------
    // Function: convolve
    //---------------------------------------------------------

    // 3D Convolution

    virtual function void convolve(
        input  int matrix_1[ ],
        input  int matrix_2[ ],
        output int matrix_3[ ],
        input  int size_1  [3],
        input  int size_2  [3],
        input  int size_3  [3]
    );
        matrix_3 = new[size_3[0] * size_3[1] * size_3[2]];
        for (int i = 0; i < size_1[2]; i++) begin
            for (int j = 0; j < size_2[2]; j++) begin
                int m1[];
                int m2[];
                int m3[];
                // Extract 2D slices
                m1 = new[size_1[0] * size_1[1]];
                m2 = new[size_2[0] * size_2[1]];
                m3 = new[size_3[0] * size_3[1]];
                for (int idx = 0; idx < size_1[0] * size_1[1]; idx++) begin
                    m1[idx] = $signed(matrix_1[size_1[0] * size_1[1] * i + idx]);
                end
                for (int idx = 0; idx < size_2[0] * size_2[1]; idx++) begin
                    m2[idx] = $signed(matrix_2[size_2[0] * size_2[1] * j + idx]);
                end
                // Perform 2D convolution
                convolve_2d(m1, m2, m3, size_1, size_2, size_3);
                // Store result
                for (int idx = 0; idx < size_3[0] * size_3[1]; idx++) begin
                    matrix_3[size_3[0] * size_3[1] * (size_2[2] * i + j) + idx] = m3[idx];
                end
            end
        end
    endfunction


    //---------------------------------------------------------
    // Function: model
    //---------------------------------------------------------

    // Main NPU model function

    virtual function void model(
        input int matrix_1[ ], input int matrix_2[ ],  output int matrix_3[ ],
        input int size_1  [3], input int size_2  [3],  input  int size_3  [3],
        input int signed zp_1, input int signed zp_2,  input  int signed zp_3,
        input int signed bias, input int signed scale, input  int shift
    );

        int m_1[ ], m_2[ ], m_3[ ];

        // Step 1: Add zero-point bias to inputs
        add_bias(matrix_1, m_1, size_1, zp_1);
        add_bias(matrix_2, m_2, size_2, zp_2);

        // Step 2: Convolution
        convolve(m_1, m_2, m_3, size_1, size_2, size_3);

        // Step 3: Add bias
        add_bias(m_3, m_3, size_3, bias);

        // Step 4: Scale and shift
        scale_shift(m_3, m_3, size_3, scale, shift);

        // Step 5: ReLU
        relu(m_3, m_3, size_3);

        // Step 6: Add zero-point bias
        add_bias(m_3, m_3, size_3, zp_3);

        // Step 7: Clamp
        clamp(m_3, matrix_3, size_3);

    endfunction

endclass
