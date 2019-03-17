
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using WebAppRestFul.Data.Models;
using WebAppRestFul.Data.Repositories;
using WebAppRestFul.Data.Repositories.Interface;
using WebAppRestFul.Extensions;
using WebAppRestFul.Filters;
using WebAppRestFul.Resources;
using WebAppRestFul.Utilities.Dtos;

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
        private readonly IProductRepository _productRepository;
        public ProductController(IConfiguration configuration,
            ILogger<ProductController> logger
            , IStringLocalizer<ProductController> localizer,
            LocService locservice, IProductRepository productRepository)
        {
            _connectionString = configuration.GetConnectionString("DbConnectionString");
            _logger = logger;
            _localizer = localizer;
            _locService = locservice;
            _productRepository = productRepository;


        }
        // GET: api/Product
        [HttpGet]
        public async Task<IEnumerable<Product>> Get()
        {
            var culture = CultureInfo.CurrentCulture.Name;
            return await _productRepository.GetAllAsync(culture);
        }

        // GET: api/Product/5
        [HttpGet("{id}", Name = "Get")]
        public async Task<Product> Get(int id)
        {
            var culture = CultureInfo.CurrentCulture.Name;
            return await _productRepository.GetByIdAsync(id, culture);
        }

        [HttpGet("Paging", Name = "GetPaging")]
        public async Task<PagedResult<Product>> GetPaging(string KeyWord, int CategoryId, int PageIndex, int PageSize)
        {
            var culture = CultureInfo.CurrentCulture.Name;
            return await _productRepository.GetPaging(KeyWord, culture, CategoryId, PageIndex, PageSize);
        }


        // POST: api/Product
        [HttpPost]
        [ValidateModel]
        public async Task<int> Post([FromBody] Product product)
        {
            var culture = CultureInfo.CurrentCulture.Name;
            return await _productRepository.Create(culture, product);
        }
        // PUT: api/Product/5
        [HttpPut("{id}")]
        [ValidateModel]
        public async Task<IActionResult> Put(int id, [FromBody] Product product)
        {
            var culture = CultureInfo.CurrentCulture.Name;
            await _productRepository.Update(culture, id, product);
            return Ok();
        }

        // DELETE: api/ApiWithActions/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _productRepository.Delete(id);
            return Ok();
        }
    }
}
