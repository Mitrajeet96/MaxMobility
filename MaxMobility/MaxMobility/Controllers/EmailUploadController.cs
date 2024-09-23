using MaxMobility.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Http.Results;
using System.Web.Mvc;

namespace MaxMobility.Controllers
{
    public class EmailUploadController : Controller
    {
        // GET: EmailUpload
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult UploadFile(HttpPostedFileBase file)
        {
            if (file != null && file.ContentLength > 0 && Path.GetExtension(file.FileName).ToLower() == ".txt")
            {
                // Extract emails from file
                var emails = ExtractEmailsFromFile(file);
                var uniqueEmails = emails.Distinct().ToList();

                // Save unique emails to the database
                var dbResult = SaveEmailsToDatabase(uniqueEmails);

                // Pass total and unique email counts to the view
                ViewBag.TotalEmails = emails.Count;
                ViewBag.UniqueEmails = uniqueEmails.Count;
                ViewBag.InsertedInDB = dbResult.InsertedCount;
                ViewBag.DuplicateInDB = dbResult.DuplicateCount;

            }
            else
            {
                ViewBag.Error = "Please upload a valid .txt file.";
            }

            return View("Index");
        }

        private List<string> ExtractEmailsFromFile(HttpPostedFileBase file)
        {
            try
            {
                var emailList = new List<string>();
                using (var reader = new StreamReader(file.InputStream))
                {
                    string content = reader.ReadToEnd();
                    string emailPattern = @"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}";
                    var emails = Regex.Matches(content, emailPattern);

                    foreach (Match email in emails)
                    {
                        emailList.Add(email.Value);
                    }
                }
                return emailList;
            }
            catch (Exception)
            {

                throw;
            }
        }

        private EmailResult SaveEmailsToDatabase(List<string> emails)
        {
            try
            {
                var result = new EmailResult();
                string connStr = ConfigurationManager.ConnectionStrings["MaxMobility"].ConnectionString;

                // Convert the list of emails to a DataTable
                DataTable emailTable = new DataTable();
                emailTable.Columns.Add("EmailID", typeof(string));
                foreach (var email in emails)
                {
                    emailTable.Rows.Add(email);
                }

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    using (SqlCommand cmd = new SqlCommand("SP_SaveEmail", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        SqlParameter tvpParam = cmd.Parameters.AddWithValue("@EmailList", emailTable);
                        tvpParam.SqlDbType = SqlDbType.Structured;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    result.InsertedCount = reader.GetInt32(0);
                                    result.DuplicateCount = reader.GetInt32(1);
                                }
                            }
                    }
                }
                return result;
            }
            catch (Exception)
            {

                throw;
            }

        }
    }
}