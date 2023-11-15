BEGIN
    SELECT * 
        FROM rooms 
        WHERE room_id NOT IN (
            SELECT reservation_room 
            FROM reservations
            WHERE 
                var_date_in < reservation_date_out AND var_date_out > reservation_date_in
                AND reservation_status <> 'cancelled'
        )         
        AND room_status <>'unavailable'
        ORDER BY rand();
END