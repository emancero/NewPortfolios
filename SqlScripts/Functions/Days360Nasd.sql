CREATE FUNCTION dbo.Days360Nasd
(
    @StartDate date,
    @EndDate   date
)
RETURNS int
AS
BEGIN
    DECLARE @d1 int = DAY(@StartDate);
    DECLARE @d2 int = DAY(@EndDate);

    -- Start date: 31st or last day of February -> 30
    IF @d1 = 31
       OR (
            MONTH(@StartDate) = 2
            AND @d1 = DAY(EOMONTH(@StartDate))
          )
    BEGIN
        SET @d1 = 30;
    END;

    -- End date: 31st -> 30 when adjusted start day is 30
    IF @d1 = 30 AND @d2 = 31
    BEGIN
        SET @d2 = 30;
    END;

    RETURN
          (YEAR(@EndDate) - YEAR(@StartDate)) * 360
        + (MONTH(@EndDate) - MONTH(@StartDate)) * 30
        + @d2 - @d1;
END