using System.Diagnostics;
using SdxCore.Identity.Application.Services;

var hasher = new PasswordHasher();

// Test 1: Hash and verify a password
Console.WriteLine("Test 1: Hash and Verify");
var password = "SecurePassword123!";
var hash = hasher.Hash(password);
Console.WriteLine($"Password: {password}");
Console.WriteLine($"Hash: {hash}");
var isValid = hasher.Verify(password, hash);
Console.WriteLine($"Verification: {isValid}");
Console.WriteLine();

// Test 2: Verify wrong password fails
Console.WriteLine("Test 2: Wrong Password");
var wrongPassword = "WrongPassword";
var isWrong = hasher.Verify(wrongPassword, hash);
Console.WriteLine($"Wrong password verification: {isWrong}");
Console.WriteLine();

// Test 3: Same password produces different hashes (salt randomization)
Console.WriteLine("Test 3: Salt Randomization");
var hash1 = hasher.Hash(password);
var hash2 = hasher.Hash(password);
Console.WriteLine($"Hash 1: {hash1}");
Console.WriteLine($"Hash 2: {hash2}");
Console.WriteLine($"Hashes are different: {hash1 != hash2}");
Console.WriteLine($"Both verify correctly: {hasher.Verify(password, hash1) && hasher.Verify(password, hash2)}");
Console.WriteLine();

// Test 4: Measure hashing time
Console.WriteLine("Test 4: Hashing Time");
var sw = Stopwatch.StartNew();
var testHash = hasher.Hash("TestPassword");
sw.Stop();
Console.WriteLine($"Hashing time: {sw.ElapsedMilliseconds}ms");
Console.WriteLine();

Console.WriteLine("All tests completed successfully!");
