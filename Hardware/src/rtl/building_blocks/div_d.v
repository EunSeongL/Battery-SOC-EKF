module div_d(
    clk,
    rst_n,
    M,
    Q,
    start,
    done,
    result_r,
    result_p
);


input clk,rst_n,start;
input signed [47:0] M,Q;
wire signed [47:0] si_M,si_Q;
output signed[47:0] result_r,result_p;
wire valid;
reg signed[97:0] total_Q;
reg [7:0] count;

output reg done;

wire r_done;

assign si_M=(valid==1'b1)?0:(M[47]==1)?~M+1:M;
assign si_Q=(valid==1'b1)?0:(Q[47]==1)?~Q+1:Q;


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin   
        count <= 49;
    end
    else
    begin
        if (start ==1)
            count <= 49;
        
        else if(count<50 && count>0)
            count <= count-1'b1; 
    end
end

wire signed[97:0] a,sh_l;




always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        total_Q<=0;
    end
    else
        begin
        if(start==1)
        begin
            total_Q<={50'b0,si_Q};
        end
        else if (count<50 && count>0)
        begin
            if(a[97]==1'b1)
            begin
                total_Q<={sh_l[97:1],1'b0};
            end
            else
                total_Q<={a[97:1],1'b1};
        end
    end

end

assign sh_l={total_Q[96:0],1'b0};
//assign a={sh_l[65:33]+(~si_M+1),sh_l[32:0]};

assign a={sh_l[97:49]+(~si_M+1),sh_l[48:0]};



assign result_r=(count!=0)?0:
                ((Q[47]==0 && M[47]==0)||(Q[47]==0 && M[47]==1))?total_Q[96:49]:
                ((Q[47]==1 && M[47]==1)||(Q[47]==1 && M[47]==0))?~(total_Q[96:49])+1:0;
assign result_p=(count!=0)?0:
                ((Q[47]==1 && M[47]==1)||(Q[47]==0 && M[47]==0))?total_Q[47:0]:
                ((Q[47]==1 && M[47]==0)||(Q[47]==0 && M[47]==1))?~(total_Q[47:0])+1:0;
assign valid=(count!=0||start==1'b1)?1'b0:1'b1;

assign r_done = (count == 1) ? 1'b1 :1'b0;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		done <= 1'b0;
	else
		done <= r_done;
end

endmodule 
