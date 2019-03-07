using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using WebAppRestFul.Dtos;
using WebAppRestFul.Extensions;
using WebAppRestFul.Filters;
using WebAppRestFul.Moadels;
using WebAppRestFul.Resources;

namespace WebAppRestFul.Controllers
{
    [Route("api/{culture}/[controller]")]
    [ApiController]
    [MiddlewareFilter(typeof(LocalizationPipeline))]
    public class ProductController : ControllerBase
    {
        private readonly string _connectionString;
        private readonly ILogger<ProductController> _logger;
        private readonly IStringLocalizer<ProductController> _localizer;
        private readonly LocService _locService;
        public ProductController(IConfiguration configuration,
            ILogger<ProductController> logger
            , IStringLocalizer<ProductController> localizer,
            LocService locservice)
        {
            _connectionString = configuration.GetConnectionString("DbConnectionString");
            _logger = logger;
            _localizer = localizer;
            _locService = locservice;


        }
        // GET: api/Product
        [HttpGet]
        public async Task<IEnumerable<Product>> Get()
        {
            var culture = CultureInfo.CurrentCulture.Name;
            //string text = _localizer["Test"];
            //string text1 = _locService.GetLocalizedHtmlString("ForgotPassword");
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@language", CultureInfo.CurrentCulture.Name);
                var result = await conn.QueryAsync<Product>("Get_Product_All", paramaters, null, null, System.Data.CommandType.StoredProcedure);
                return result;
            }
        }

        // GET: api/Product/5
        [HttpGet("{id}", Name = "Get")]
        public async Task<Product> Get(int id)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == System.Data.ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@id", id);
                paramaters.Add("@language", CultureInfo.CurrentCulture.Name);
                var result = await conn.QueryAsync<Product>("Get_Product_ById", paramaters, null, null, System.Data.CommandType.StoredProcedure);
                return result.Single();
            }
        }

        [HttpGet("Paging", Name = "GetPaging")]
        public async Task<PagedResult<Product>> GetPaging(string KeyWord, int CategoryId, int PageIndex, int PageSize)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == System.Data.ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@keyWord", KeyWord);
                paramaters.Add("@categoryId", CategoryId);
                paramaters.Add("@pageIndex", PageIndex);
                paramaters.Add("@pageSize", PageSize);
                paramaters.Add("@language", CultureInfo.CurrentCulture.Name);
                paramaters.Add("@totalRow", dbType: DbType.Int32, direction: ParameterDirection.Output);
                var result = await conn.QueryAsync<Product>("Get_Product_AllPaging", paramaters, null, null, CommandType.StoredProcedure);
                int totalRow = paramaters.Get<int>("@totalRow");
                return new PagedResult<Product>()
                {
                    Items = result.ToList(),
                    TotalRow = totalRow,
                    PageIndex = PageIndex,
                    PageSize = PageSize
                };
            }
        }


        // POST: api/Product
        [HttpPost]
        [ValidateModel]
        public async Task<IActionResult> Post([FromBody] Product product)
        {

            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@name", product.Name);
                paramaters.Add("@description", product.Description);
                paramaters.Add("@content", product.Content);
                paramaters.Add("@seoDescription", product.SeoDescription);
                paramaters.Add("@seoAlias", product.SeoAlias);
                paramaters.Add("@seoTitle", product.SeoTitle);
                paramaters.Add("@seoKeyword", product.SeoKeyword);
                paramaters.Add("@sku", product.Sku);
                paramaters.Add("@price", product.Price);
                paramaters.Add("@isActive", product.IsActive);
                paramaters.Add("@imageUrl", product.ImageUrl);
                paramaters.Add("@language", CultureInfo.CurrentCulture.Name);
                paramaters.Add("@categoryIds", product.CategoryIds);
                paramaters.Add("@id", dbType: DbType.Int32, direction: ParameterDirection.Output);
                var result = await conn.ExecuteAsync("Create_Product", paramaters, null, null, System.Data.CommandType.StoredProcedure);

                int newId = paramaters.Get<int>("@id");
                return Ok(newId);
            }
        }
        // PUT: api/Product/5
        [HttpPut("{id}")]
        [ValidateModel]
        public async Task<IActionResult> Put(int id, [FromBody] Product product)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();

                paramaters.Add("@id", id);
                paramaters.Add("@name", product.Name);
                paramaters.Add("@description", product.Description);
                paramaters.Add("@content", product.Content);
                paramaters.Add("@seoDescription", product.SeoDescription);
                paramaters.Add("@seoAlias", product.SeoAlias);
                paramaters.Add("@seoTitle", product.SeoTitle);
                paramaters.Add("@seoKeyword", product.SeoKeyword);
                paramaters.Add("@sku", product.Sku);
                paramaters.Add("@price", product.Price);
                paramaters.Add("@isActive", product.IsActive);
                paramaters.Add("@imageUrl", product.ImageUrl);
                paramaters.Add("@language", CultureInfo.CurrentCulture.Name);
                paramaters.Add("@categoryIds", product.CategoryIds);
                await conn.ExecuteAsync("Update_Product", paramaters, null, null, CommandType.StoredProcedure);
                return Ok();
            }
        }

        // DELETE: api/ApiWithActions/5
        [HttpDelete("{id}")]
        public async Task Delete(int id)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == System.Data.ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@id", id);
                paramaters.Add("@language", CultureInfo.CurrentCulture.Name);
                await conn.ExecuteAsync("Delete_Product_ById", paramaters, null, null, CommandType.StoredProcedure);
            }
        }
    }
}
