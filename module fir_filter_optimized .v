module fir_filter_optimized (
    input clk,
    input rst_n,
    input [7:0] x,
    output reg [7:0] y
);

    reg [7:0] x_reg [3:0]; // 4-stage pipeline for input
    reg [7:0] h [3:0] = {8'h19, 8'h33, 8'h66, 8'h33}; // Coefficients
    reg [15:0] acc; // Accumulator for sum
    reg [15:0] acc_pipeline [3:0]; // 4-stage pipeline for accumulator

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            y <= 8'h0;
        else 
            y <= acc_pipeline[3][15:8]; // Take the MSBs if fixed-point numbers are used
    end

    // Pipelining the calculations
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_pipeline[0] <= 16'h0;
            acc_pipeline[1] <= 16'h0;
            acc_pipeline[2] <= 16'h0;
            acc_pipeline[3] <= 16'h0;
        end else begin
            acc_pipeline[0] <= (h[0] * x_reg[0]);
            acc_pipeline[1] <= acc_pipeline[0] + (h[1] * x_reg[1]);
            acc_pipeline[2] <= acc_pipeline[1] + (h[2] * x_reg[2]);
            acc_pipeline[3] <= acc_pipeline[2] + (h[3] * x_reg[3]);
        end
    end

    // Update the input register pipeline
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_reg[0] <= 8'h0;
            x_reg[1] <= 8'h0;
            x_reg[2] <= 8'h0;
            x_reg[3] <= 8'h0;
        end else begin
            x_reg[3] <= x_reg[2];
            x_reg[2] <= x_reg[1];
            x_reg[1] <= x_reg[0];
            x_reg[0] <= x;
        end
    end

endmodule
