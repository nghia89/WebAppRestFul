using Dapper;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using WebAppRestFul.Data.Models;
using WebAppRestFul.Data.Repositories.Interface;
using WebAppRestFul.Data.ViewModels;
using WebAppRestFul.Utilities.Dtos;

namespace WebAppRestFul.Data.Repositories
{
    public class ProductRepository: IProductRepository
    {
        private readonly string _connectionString;
        private readonly ILogger<ProductRepository> _logger;

        public ProductRepository(IConfiguration configuration, ILogger<ProductRepository> logger)
        {
            _logger = logger;
            _connectionString = configuration.GetConnectionString("DbConnectionString");
        }
        public async Task<IEnumerable<Product>> GetAllAsync(string culture)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();

                var paramaters = new DynamicParameters();
                paramaters.Add("@language", culture);

                var result = await conn.QueryAsync<Product>("Get_Product_All", paramaters, null, null, CommandType.StoredProcedure);
                return result;
            }
        }

        public async Task<Product> GetByIdAsync(int id, string culture)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@id", id);
                paramaters.Add("@language", culture);

                var result = await conn.QueryAsync<Product>("Get_Product_ById", paramaters, null, null, CommandType.StoredProcedure);
                return result.Single();
            }
        }

        public async Task<PagedResult<Product>> GetPaging(string keyword, string culture, int categoryId, int pageIndex, int pageSize)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@keyword", keyword);
                paramaters.Add("@categoryId", categoryId);
                paramaters.Add("@pageIndex", pageIndex);
                paramaters.Add("@pageSize", pageSize);
                paramaters.Add("@language", culture);

                paramaters.Add("@totalRow", dbType: DbType.Int32, direction: ParameterDirection.Output);

                var result = await conn.QueryAsync<Product>("Get_Product_AllPaging", paramaters, null, null, CommandType.StoredProcedure);

                int totalRow = paramaters.Get<int>("@totalRow");

                var pagedResult = new PagedResult<Product>()
                {
                    Items = result.ToList(),
                    TotalRow = totalRow,
                    PageIndex = pageIndex,
                    PageSize = pageSize
                };
                return pagedResult;
            }
        }

        public async Task<int> Create(string culture, Product product)
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
                paramaters.Add("@language", culture);
                paramaters.Add("@categoryIds", product.CategoryIds);
                paramaters.Add("@id", dbType: DbType.Int32, direction: ParameterDirection.Output);
                var result = await conn.ExecuteAsync("Create_Product", paramaters, null, null, CommandType.StoredProcedure);

                int newId = paramaters.Get<int>("@id");
                return newId;
            }
        }

        public async Task Update(string culture, int id, Product product)
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
                paramaters.Add("@language", culture);
                paramaters.Add("@categoryIds", product.CategoryIds);
                await conn.ExecuteAsync("Update_Product", paramaters, null, null, CommandType.StoredProcedure);
            }

        }

        public async Task Delete(int id)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@id", id);
                await conn.ExecuteAsync("Delete_Product_ById", paramaters, null, null, CommandType.StoredProcedure);
            }
        }

        public async Task<List<ProductAttributeViewModel>> GetAttributes(int id, string culture)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@id", id);
                paramaters.Add("@language", culture);

                var result = await conn.QueryAsync<ProductAttributeViewModel>("Get_Product_Attributes", paramaters, null, null, CommandType.StoredProcedure);
                return result.ToList();
            }
        }

        public async Task<PagedResult<Product>> SearchByAttributes(string keyword, string culture,
            int categoryId, string size, int pageIndex, int pageSize)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();

                var paramaters = new DynamicParameters();
                paramaters.Add("@keyword", keyword);
                paramaters.Add("@categoryId", categoryId);
                paramaters.Add("@pageIndex", pageIndex);
                paramaters.Add("@pageSize", pageSize);
                paramaters.Add("@language", culture);
                paramaters.Add("@size", size);

                paramaters.Add("@totalRow", dbType: DbType.Int32,
                    direction: ParameterDirection.Output);

                var result = await conn.QueryAsync<Product>("[Search_Product_ByAttributes]",
                    paramaters, null, null, CommandType.StoredProcedure);

                int totalRow = paramaters.Get<int>("@totalRow");

                var pagedResult = new PagedResult<Product>()
                {
                    Items = result.ToList(),
                    TotalRow = totalRow,
                    PageIndex = pageIndex,
                    PageSize = pageSize
                };
                return pagedResult;
            }
        }
    }
}
