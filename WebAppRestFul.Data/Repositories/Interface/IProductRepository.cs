using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using WebAppRestFul.Data.Models;
using WebAppRestFul.Data.ViewModels;
using WebAppRestFul.Utilities.Dtos;

namespace WebAppRestFul.Data.Repositories.Interface
{
    public interface IProductRepository
    {
        Task<IEnumerable<Product>> GetAllAsync(string culture);
        Task<Product> GetByIdAsync(int id, string culture);

        Task<PagedResult<Product>> GetPaging(string keyword, string culture, int categoryId, int pageIndex, int pageSize);

        Task<int> Create(string culture, Product product);

        Task Update(string culture, int id, Product product);

        Task Delete(int id);

        Task<List<ProductAttributeViewModel>> GetAttributes(int id, string culture);

        Task<PagedResult<Product>> SearchByAttributes(string keyword, string culture,
            int categoryId, string size, int pageIndex, int pageSize);
    }
}
