using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SdxCore.Identity.Domain.DTOs;
 public class RefreshTokenResult
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; } 

    public string RawToken { get; set; } = default!;
    public string HashToken { get; set; } = default!;

    public DateTimeOffset ExpiresAt { get; set; }
}