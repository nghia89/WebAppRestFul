﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using WebAppRestFul.Dtos;
using WebAppRestFul.Filters;
using WebAppRestFul.Moadels;

namespace WebAppRestFul.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly string _connectionString;
        public ProductController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DbConnectionString");
        }
        // GET: api/Product
        [HttpGet]
        public async Task<IEnumerable<Product>> Get()
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == System.Data.ConnectionState.Closed)
                    conn.Open();
                var result = await conn.QueryAsync<Product>("Get_Product_All", null, null, null, System.Data.CommandType.StoredProcedure);
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
                var result = await conn.QueryAsync<Product>("Get_Product_ById", paramaters, null, null, System.Data.CommandType.StoredProcedure);
                return result.Single();
            }
        }

        [HttpGet("Paging",Name ="GetPaging")]
        public async Task<PagedResult<Product>> GetPaging(string KeyWord,int CategoryId,int PageIndex,int PageSize)
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
                paramaters.Add("@totalRow",dbType:DbType.Int32,direction:ParameterDirection.Output);
                var result = await conn.QueryAsync<Product>("Get_Product_AllPaging", paramaters, null, null,CommandType.StoredProcedure);
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
        public async Task<int> Post([FromBody] Product product)
        {
            int newId = 0;
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == System.Data.ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@sku", product.Sku);
                paramaters.Add("@price", product.Price);
                paramaters.Add("@isActive", product.Sku);
                paramaters.Add("@imageUrl", product.ImageUrl);
                paramaters.Add("@id", dbType: DbType.Int32, direction: ParameterDirection.Output);
                var result = await conn.ExecuteAsync("Create_Product", paramaters, null, null,CommandType.StoredProcedure);

                newId = paramaters.Get<int>("@id");
            }
            return newId;
        }
        // PUT: api/Product/5
        [HttpPut("{id}")]
        [ValidateModel]
        public async Task Put(int id, [FromBody] Product product)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                if (conn.State == System.Data.ConnectionState.Closed)
                    conn.Open();
                var paramaters = new DynamicParameters();
                paramaters.Add("@id", id);
                paramaters.Add("@sku", product.Sku);
                paramaters.Add("@price", product.Price);
                paramaters.Add("@isActive", product.Sku);
                paramaters.Add("@imageUrl", product.ImageUrl);
                await conn.ExecuteAsync("Update_Product", paramaters, null, null,CommandType.StoredProcedure);
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
                await conn.ExecuteAsync("Delete_Product_ById", paramaters, null, null, CommandType.StoredProcedure);
            }
        }
    }
}
