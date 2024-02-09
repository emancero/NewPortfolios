using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
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

    [Serializable]
    [SqlUserDefinedAggregate(
        Format.UserDefined, //use clr serialization to serialize the intermediate result
        Name = "CLRSortedCssvAgg", //aggregate name on sql
        IsInvariantToNulls = true, //optimizer property
        IsInvariantToDuplicates = false, //optimizer property
        IsInvariantToOrder = false, //optimizer property
        IsNullIfEmpty = false, //optimizer property
        MaxByteSize = -1) //maximum size in bytes of persisted value
    ]

    public class SortedCssvConcatenateAgg : IBinarySerialize
    {
        /// <summary>
        /// The variable that holds all the strings to be aggregated.
        /// </summary>
        List<string> aggregationList;

        StringBuilder accumulator;

        /// <summary>
        /// Separator between concatenated values.
        /// </summary>
        const string CommaSpaceSeparator = "-";

        /// <summary>
        /// Initialize the internal data structures.
        /// </summary>
        public void Init()
        {
            accumulator = new StringBuilder();
            aggregationList = new List<string>();
        }

        /// <summary>
        /// Accumulate the next value, not if the value is null or empty.
        /// </summary>
        public void Accumulate(SqlString value)
        {
            if (value.IsNull || String.IsNullOrEmpty(value.Value))
            {
                return;
            }

            aggregationList.Add(value.Value);
        }

        /// <summary>
        /// Merge the partially computed aggregate with this aggregate.
        /// </summary>
        /// <param name="other"></param>
        public void Merge(SortedCssvConcatenateAgg other)
        {
            aggregationList.AddRange(other.aggregationList);
        }

        /// <summary>
        /// Called at the end of aggregation, to return the results of the aggregation.
        /// </summary>
        /// <returns></returns>
        public SqlString Terminate()
        {
            string _Aggregation = null;

            if (aggregationList != null && aggregationList.Count > 0)
            {
                aggregationList.Sort();
                _Aggregation = string.Join(CommaSpaceSeparator, aggregationList);
                _Aggregation = System.Text.RegularExpressions.Regex.Replace(_Aggregation, @"[\d-]", string.Empty);
            }

            return new SqlString(_Aggregation);
        }

        public void Read(BinaryReader r)
        {
            int _Count = r.ReadInt32();
            aggregationList = new List<string>(_Count);

            for (int _Index = 0; _Index < _Count; _Index++)
            {
                aggregationList.Add(r.ReadString());
            }
        }

        public void Write(BinaryWriter w)
        {
            w.Write(aggregationList.Count);
            foreach (string _Item in aggregationList)
            {
                w.Write(_Item);
            }
        }
    }

