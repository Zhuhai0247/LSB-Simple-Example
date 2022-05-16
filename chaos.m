function [chaos_array] = chaos(u,x)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
    chaos_array = (256*256);
    for i=1:256*256
        chaos_array(1,i)=x;
        x = x*u*(1-x);
    end
end