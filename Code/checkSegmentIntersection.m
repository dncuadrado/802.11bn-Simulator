function isIntersecting = checkSegmentIntersection(x1a1, x2a1, y1a1, y2a1, x1a2, x2a2, y1a2, y2a2)
    %%% Return a "1" if segment a1 "crosses" segment a2. This function is used to determine whether the tx defined by
    %%% the two points contained in a1 (4 coordinate values: x1a1, x2a1, y1a1, y2a1) goes across the wall defined by
    %%% segment a2

    % Helper function to calculate orientation
    function o = orientation(p, q, r)
        val = (q(2) - p(2)) * (r(1) - q(1)) - (q(1) - p(1)) * (r(2) - q(2));
        if val == 0
            o = 0; % Collinear
        elseif val > 0
            o = 1; % Clockwise
        else
            o = 2; % Counterclockwise
        end
    end

    % Helper function to check if a point is on a segment
    function is_on = on_segment(p, q, r)
        is_on = min(p(1), r(1)) <= q(1) && q(1) <= max(p(1), r(1)) && ...
                min(p(2), r(2)) <= q(2) && q(2) <= max(p(2), r(2));
    end

    % Define the endpoints
    p1 = [x1a1, y1a1]; q1 = [x2a1, y2a1];
    p2 = [x1a2, y1a2]; q2 = [x2a2, y2a2];

    % Calculate orientations
    o1 = orientation(p1, q1, p2);
    o2 = orientation(p1, q1, q2);
    o3 = orientation(p2, q2, p1);
    o4 = orientation(p2, q2, q1);

    % General case
    if o1 ~= o2 && o3 ~= o4
        isIntersecting = true;
        return;
    end

    % Special cases
    if o1 == 0 && on_segment(p1, p2, q1), isIntersecting = true; return; end
    if o2 == 0 && on_segment(p1, q2, q1), isIntersecting = true; return; end
    if o3 == 0 && on_segment(p2, p1, q2), isIntersecting = true; return; end
    if o4 == 0 && on_segment(p2, q1, q2), isIntersecting = true; return; end

    isIntersecting = false;
end