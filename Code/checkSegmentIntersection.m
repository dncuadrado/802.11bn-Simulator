function isIntersecting = checkSegmentIntersection(a1, a2)
    %%% Return a "1" if segment a1 "crosses" segment a2. This function is used to determine whether the tx defined by
    %%% the two points contained in a1 (4 coordinate values: x1a1, x2a1, y1a1, y2a1) goes across the wall defined by
    %%% segment a2

    % Extract coordinates from vectors
    x1a1 = a1(1);
    x2a1 = a1(2);
    y1a1 = a1(3);
    y2a1 = a1(4);

    x1a2 = a2(1);
    x2a2 = a2(2);
    y1a2 = a2(3);
    y2a2 = a2(4);

    % Calculate slopes
    slope_a1 = (y2a1 - y1a1) / (x2a1 - x1a1);
    slope_a2 = (y2a2 - y1a2) / (x2a2 - x1a2);

    % Check if segments are parallel
    if abs(slope_a1 - slope_a2) < eps
        % Segments are parallel, check if they overlap
        if ((x1a1 >= x1a2 && x1a1 <= x2a2) || (x2a1 >= x1a2 && x2a1 <= x2a2)) ...
           && ((y1a1 >= y1a2 && y1a1 <= y2a2) || (y2a1 >= y1a2 && y2a1 <= y2a2))
            isIntersecting = true;
        else
            isIntersecting = false;
        end
    else
        % Segments are not parallel, check for intersection point
        t = ((x1a1 - x1a2) * (y1a2 - y2a2) - (y1a1 - y1a2) * (x1a2 - x2a2)) / ...
            ((x1a1 - x2a1) * (y1a2 - y2a2) - (y1a1 - y2a1) * (x1a2 - x2a2));

        if t >= 0 && t <= 1
            isIntersecting = true;
        else
            isIntersecting = false;
        end
    end
end