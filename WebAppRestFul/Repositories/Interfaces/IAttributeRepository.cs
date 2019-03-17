using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using WebAppRestFul.Data.ViewModels;

namespace WebAppRestFul.Repositories.Interfaces
{
    public interface IAttributeRepository
    {
        Task<List<AttributeViewModel>> GetAll(string culture);

        Task<AttributeViewModel> GetById(int id, string culture);

        Task Add(string culture, AttributeViewModel attribute);

        Task Update(int id, string culture, AttributeViewModel attribute);

        Task Delete(int id);
    }
}
