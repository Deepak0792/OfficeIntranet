namespace SdxCore.Attendance.Application.DTOs.Holiday.Response;

public class EmployeeHolidaySummaryResponse
{
    public int TotalHolidays { get; set; }

    public int NationalHolidays { get; set; }

    public int StateHolidays { get; set; }

    public int ReligiousHolidays { get; set; }

    public IReadOnlyCollection<EmployeeHolidayResponse> Holidays { get; set; }
        = [];
}