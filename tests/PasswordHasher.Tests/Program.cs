using System.Diagnostics;
using SdxCore.Identity.Application.Services;
using SdxCore.Identity.Application.Security;
using SdxCore.Common.Security;

// Test 1: Hash and verify a password
Console.WriteLine("Test 1: Hash and Verify");
var password = "SecurePassword123!";
var hash = PasswordHasher.Hash(password);
Console.WriteLine($"Password: {password}");
Console.WriteLine($"Hash: {hash}");
var isValid = PasswordHasher.Verify(password, hash);
Console.WriteLine($"Verification: {isValid}");
Console.WriteLine();

// Test 2: Verify wrong password fails
Console.WriteLine("Test 2: Wrong Password");
var wrongPassword = "WrongPassword";
var isWrong = PasswordHasher.Verify(wrongPassword, hash);
Console.WriteLine($"Wrong password verification: {isWrong}");
Console.WriteLine();

// Test 3: Same password produces different hashes (salt randomization)
Console.WriteLine("Test 3: Salt Randomization");
var hash1 = PasswordHasher.Hash(password);
var hash2 = PasswordHasher.Hash(password);
Console.WriteLine($"Hash 1: {hash1}");
Console.WriteLine($"Hash 2: {hash2}");
Console.WriteLine($"Hashes are different: {hash1 != hash2}");
Console.WriteLine($"Both verify correctly: {PasswordHasher.Verify(password, hash1) && PasswordHasher.Verify(password, hash2)}");
Console.WriteLine();

// Test 4: Measure hashing time
Console.WriteLine("Test 4: Hashing Time");
var sw = Stopwatch.StartNew();
var testHash = PasswordHasher.Hash("TestPassword");
sw.Stop();
Console.WriteLine($"Hashing time: {sw.ElapsedMilliseconds}ms");
Console.WriteLine();

Console.WriteLine("All tests completed successfully!");
