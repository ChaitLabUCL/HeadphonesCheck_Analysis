function y = rNan(x)

if iscell(x)
    y =  x(~cellfun('isempty',x));
else
    idx = ~isnan(x);
    y=x(idx);
end
