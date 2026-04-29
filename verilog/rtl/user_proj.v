`default_nettype none
module tt_um_stoch_alu (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    inout  wire [7:0] uio,
    input  wire       clk,
    input  wire       rst_n
);

    // Decodificación de pines
    wire [3:0] op_b       = uio[3:0];
    wire [2:0] opcode     = uio[6:4];
    wire       stoch_mode = uio[7];

    // LFSR 8-bit para streams estocásticos
    reg [7:0] lfsr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) lfsr <= 8'h1B;
        else lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
    end

    // Generadores de números estocásticos (SNG)
    wire [7:0] operand_b_ext = {4'b0, op_b};
    wire a_stream = (ui_in > lfsr);
    wire b_stream = (operand_b_ext > lfsr);

    // Operaciones estocásticas
    wire stoch_mul  = a_stream & b_stream;
    wire stoch_add  = (lfsr[7]) ? a_stream : b_stream;
    wire stoch_and  = a_stream & b_stream;
    wire stoch_or   = a_stream | b_stream;
    wire stoch_xor  = a_stream ^ b_stream;

    wire stoch_result = (opcode == 3'd0) ? stoch_mul  :
                        (opcode == 3'd1) ? stoch_add  :
                        (opcode == 3'd2) ? stoch_and  :
                        (opcode == 3'd3) ? stoch_or   :
                        (opcode == 3'd4) ? stoch_xor  : a_stream;

    // Operaciones exactas (modo fallback y referencia)
    wire [7:0] exact_add = ui_in + operand_b_ext;
    wire [7:0] exact_sub = ui_in - operand_b_ext;
    wire [11:0] exact_mul_full = ui_in * operand_b_ext;
    wire [7:0] exact_mul = exact_mul_full[7:0];
    wire [7:0] exact_and = ui_in & operand_b_ext;
    wire [7:0] exact_or  = ui_in | operand_b_ext;
    wire [7:0] exact_xor = ui_in ^ operand_b_ext;

    wire [7:0] exact_result = (opcode == 3'd0) ? exact_mul  :
                              (opcode == 3'd1) ? exact_add  :
                              (opcode == 3'd2) ? exact_sub  :
                              (opcode == 3'd3) ? exact_mul  :
                              (opcode == 3'd4) ? exact_and  :
                              (opcode == 3'd5) ? exact_or   :
                              (opcode == 3'd6) ? exact_xor  : ui_in;

    // Convertidor Stream -> Binario (Contador de población, 64 ciclos)
    reg [5:0] sample_counter;
    reg [6:0] pop_count;
    reg [7:0] final_result;
    reg       confidence_flag;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_counter <= 6'd0;
            pop_count <= 7'd0;
            final_result <= 8'd0;
            confidence_flag <= 1'b1;
        end else if (stoch_mode) begin
            if (sample_counter < 6'd63) begin
                sample_counter <= sample_counter + 1'd1;
                if (stoch_result) pop_count <= pop_count + 1'd1;
            end else begin
                final_result <= {pop_count[6:0], 2'b00}; // Escalar x4
                if ((pop_count < 7'd10) || (pop_count > 7'd54))
                    confidence_flag <= 1'b1;
                else
                    confidence_flag <= 1'b0;
                sample_counter <= 6'd0;
                pop_count <= 7'd0;
            end
        end else begin
            final_result <= exact_result;
            confidence_flag <= 1'b1;
        end
    end

    // Salida registrada
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) uo_out <= 8'h00;
        else uo_out <= {confidence_flag, final_result[6:0]};
    end

    assign uio = 8'hzz;
`default_nettype wire
endmodule
