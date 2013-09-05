% Show model result

if use_model
    pair=get_X(D, num);

    warning off % Ignore causa test warnings
    score=exec(mymodel, pair)
    warning on

    set(n4, 'String', sprintf('%5.2f', score));
end