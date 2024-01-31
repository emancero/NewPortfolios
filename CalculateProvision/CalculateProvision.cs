using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    static DateTime GetEom(DateTime fecha)
    {
        return new DateTime(fecha.Year, fecha.Month, DateTime.DaysInMonth(fecha.Year, fecha.Month));
    }

    static DateTime GetFirstDay(DateTime fechaCorte)
    {
        int month = fechaCorte.Month;
        int year = fechaCorte.Year;
        return new DateTime(year, month, 1, 0, 0, 0);
    }

    [Microsoft.SqlServer.Server.SqlFunction]
    public static double CalculateProvision(double quantity, DateTime couponIni, DateTime dateEnd, double interestRate, int calcBase, DateTime valueDate, double interestAccruedDays, bool table)
    {
        DateTime dateIni = valueDate > couponIni ? valueDate : couponIni;
        DateTime ini = GetEom(dateIni);
        DateTime end = GetEom(dateEnd.Date);
        int accDays = 0;

        for (DateTime eom = ini; eom < end; eom = GetEom(eom.AddMonths(1)))
        {
            int days = 0;
            DateTime startOfMonth = GetFirstDay(eom);
            if (dateIni > eom) days = 0;
            else if (dateIni < startOfMonth)
            {
                if (eom.Month == 2)
                    days = 28;
                else
                    days = 30;
            }
            else if (dateIni >= startOfMonth)
                days = (eom - dateIni).Days;

            double interest = quantity * days / 360.0 * interestRate / 100.0;
            accDays += days;

        }
        return quantity * accDays / 360.0 * interestRate / 100.0;
    }

}
