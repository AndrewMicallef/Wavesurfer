function result=objectFunctionUnary(funkshun,arg)
    result=ws.utility.objectArray(class(arg),size(arg));
    n=numel(arg);
    for i=1:n ,
        result(i)=feval(funkshun,arg(i));
    end
end
