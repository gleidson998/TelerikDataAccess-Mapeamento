param($installPath, $toolsPath, $package, $project)
	
	. (Join-Path $toolsPath "cleanProject.ps1")

#Add the proper EnhancerAssembly project setting
$enhancerFile = [System.IO.Path]::Combine($toolsPath, 'enhancer\enhancer.exe')
$enhancerUri = new-object Uri($enhancerFile)
$solutionUri = new-object Uri($project.DTE.Solution.FullName)
$enhancerRelativeUri = $solutionUri.MakeRelativeUri($enhancerUri)
$enhancerRelativePath = $enhancerRelativeUri.ToString().Replace([System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)
if($enhancerRelativeUri.IsAbsoluteUri)
{
	# The Enhancer path is Absolute
	if($enhancerRelativePath.StartsWith("file:"))
	{
		# Avoid getting "file:file:" for files on Shared Drive
		$enhancerRelativePath = $enhancerRelativePath.Substring(5);
	}

	# We don't need to concat the Absolute path with the SolutionDir
	$msbuild.Xml.AddProperty('EnhancerAssembly', $enhancerRelativePath) | out-null
}
else
{
	# The NuGet repository is Relative to the Solution so we need to concat it with the SolutionDir.
	$msbuild.Xml.AddProperty('EnhancerAssembly','$(SolutionDir)\' + $enhancerRelativePath) | out-null
}

# Include the new OpenAccess targets right after the CSharp/VisualBasic targets in order to be before the
# NuGet targets ensuring that the packages restore will be executed before the Enhancement
$openAccessTargetsImport = $msbuild.Xml.CreateImportElement('OpenAccessNuget.targets');
$msTargetsImport = $null
if($project.Type -eq "C#")
{
	$msTargetsImport = $msbuild.Xml.Imports | Where-Object { $_.Project.EndsWith("Microsoft.CSharp.targets") }
}
elseif($project.Type -eq "VB.NET")
{
	$msTargetsImport = $msbuild.Xml.Imports | Where-Object { $_.Project.EndsWith("Microsoft.VisualBasic.targets") }
}

if($msTargetsImport -ne $null)
{
	$msbuild.Xml.InsertAfterChild($openAccessTargetsImport, $msTargetsImport)
}
else
{
	$msbuild.Xml.AddImport($openAccessTargetsImport) 
}

# Save the project
$project.Save()
# SIG # Begin signature block
# MIIXoAYJKoZIhvcNAQcCoIIXkTCCF40CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+E2LAGzg2+uqQHzW6SWDOQ3h
# CpygghLGMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTMMIIDtKADAgECAhAzx7q9dVrb3SCyJ6xL/rqFMA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTE2MTIwNTAwMDAwMFoX
# DTE4MTIyMTIzNTk1OVowZDELMAkGA1UEBhMCQkcxDjAMBgNVBAgMBVNvZmlhMQ4w
# DAYDVQQHDAVTb2ZpYTETMBEGA1UECgwKVEVMRVJJSyBBRDELMAkGA1UECwwCSVQx
# EzARBgNVBAMMClRFTEVSSUsgQUQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDUWlr3Il6cjcUCipysOdAbuQRAJRvpX1cU1Bf5e526re0Dk8EAT9H8HV15
# QpD5GtmwaDzW8MHEJSDRGxeOoZvqfbHBecOo0LbKhlThndSbz3KMWzSZj3SqxZf6
# W526BiKOz+doiRX7Ot0grg1UotisSXYrwQCXkFFQGPHsYgpOhb7CPfjwaxlvoXWR
# fDslXXK+xtGPBiIp757QR7G5HREKcdoJrqyqsBzssHxje0cpFXmyivQIclgmhEJQ
# yfTXLT2oxtu1wJG2u5GehBrSVb+uMhUPMOFK35sM4GL/mV6sbFqHUzfBx/bMeYcw
# kd2Qvy0QHYIj1e95JRsNfru9nGt3AgMBAAGjggFdMIIBWTAJBgNVHRMEAjAAMA4G
# A1UdDwEB/wQEAwIHgDArBgNVHR8EJDAiMCCgHqAchhpodHRwOi8vc3Yuc3ltY2Iu
# Y29tL3N2LmNybDBhBgNVHSAEWjBYMFYGBmeBDAEEATBMMCMGCCsGAQUFBwIBFhdo
# dHRwczovL2Quc3ltY2IuY29tL2NwczAlBggrBgEFBQcCAjAZDBdodHRwczovL2Qu
# c3ltY2IuY29tL3JwYTATBgNVHSUEDDAKBggrBgEFBQcDAzBXBggrBgEFBQcBAQRL
# MEkwHwYIKwYBBQUHMAGGE2h0dHA6Ly9zdi5zeW1jZC5jb20wJgYIKwYBBQUHMAKG
# Gmh0dHA6Ly9zdi5zeW1jYi5jb20vc3YuY3J0MB8GA1UdIwQYMBaAFJY7U/B5M5ev
# fYPvLivMyreGHnJmMB0GA1UdDgQWBBSyKcHh97Gn6HMRM1wTMVaTsCzRKTANBgkq
# hkiG9w0BAQsFAAOCAQEAYmJfOhPyFGHLo4JD738DMmcj6RHx8cMDKSsfnU4S+sZE
# fi14vQFIVDBeDU8AWxAva7oWYHugzDmsgiEXYUhoH8fwG/CQgLGRkf9Ssm9hT32+
# 2uyzETwQbvo025QxcDIVBdpK6jtqs8tABsUff1IWZbLjSsjyZBv7RTNqV14NDL8B
# 2YJel90Z3QvvcKi8yNAapbLXOiDdK/Ii0ui9AFn2fzzciPJoORdn++Zkn8pQUUbf
# KJaFag042YL2duJ7HQBM9w3dXeCO2MucZ+Oo/+dPg4VCr83+Rvgk/mHq3Jm3fmlQ
# 8vVG04m+TJ+t/fl3NFGFoKDsbZFV5AyUqZMakVoUFzCCBVkwggRBoAMCAQICED14
# 1/l2SWCyYX308B7KhiowDQYJKoZIhvcNAQELBQAwgcoxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3Qg
# TmV0d29yazE6MDgGA1UECxMxKGMpIDIwMDYgVmVyaVNpZ24sIEluYy4gLSBGb3Ig
# YXV0aG9yaXplZCB1c2Ugb25seTFFMEMGA1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQ
# dWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEc1MB4XDTEz
# MTIxMDAwMDAwMFoXDTIzMTIwOTIzNTk1OVowfzELMAkGA1UEBhMCVVMxHTAbBgNV
# BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVz
# dCBOZXR3b3JrMTAwLgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2Rl
# IFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCXgx4A
# Fq8ssdIIxNdok1FgHnH24ke021hNI2JqtL9aG1H3ow0Yd2i72DarLyFQ2p7z518n
# TgvCl8gJcJOp2lwNTqQNkaC07BTOkXJULs6j20TpUhs/QTzKSuSqwOg5q1PMIdDM
# z3+b5sLMWGqCFe49Ns8cxZcHJI7xe74xLT1u3LWZQp9LYZVfHHDuF33bi+VhiXjH
# aBuvEXgamK7EVUdT2bMy1qEORkDFl5KK0VOnmVuFNVfT6pNiYSAKxzB3JBFNYoO2
# untogjHuZcrf+dWNsjXcjCtvanJcYISc8gyUXsBWUgBIzNP4pX3eL9cT5DiohNVG
# uBOGwhud6lo43ZvbAgMBAAGjggGDMIIBfzAvBggrBgEFBQcBAQQjMCEwHwYIKwYB
# BQUHMAGGE2h0dHA6Ly9zMi5zeW1jYi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBs
# BgNVHSAEZTBjMGEGC2CGSAGG+EUBBxcDMFIwJgYIKwYBBQUHAgEWGmh0dHA6Ly93
# d3cuc3ltYXV0aC5jb20vY3BzMCgGCCsGAQUFBwICMBwaGmh0dHA6Ly93d3cuc3lt
# YXV0aC5jb20vcnBhMDAGA1UdHwQpMCcwJaAjoCGGH2h0dHA6Ly9zMS5zeW1jYi5j
# b20vcGNhMy1nNS5jcmwwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMDMA4G
# A1UdDwEB/wQEAwIBBjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRU3ltYW50ZWNQ
# S0ktMS01NjcwHQYDVR0OBBYEFJY7U/B5M5evfYPvLivMyreGHnJmMB8GA1UdIwQY
# MBaAFH/TZafC3ey78DAJ80M5+gKvMzEzMA0GCSqGSIb3DQEBCwUAA4IBAQAThRoe
# aak396C9pK9+HWFT/p2MXgymdR54FyPd/ewaA1U5+3GVx2Vap44w0kRaYdtwb9oh
# BcIuc7pJ8dGT/l3JzV4D4ImeP3Qe1/c4i6nWz7s1LzNYqJJW0chNO4LmeYQW/Ciw
# sUfzHaI+7ofZpn+kVqU/rYQuKd58vKiqoz0EAeq6k6IOUCIpF0yH5DoRX9akJYmb
# BWsvtMkBTCd7C6wZBSKgYBU/2sn7TUyP+3Jnd/0nlMe6NQ6ISf6N/SivShK9DbOX
# Bd5EDBX6NisD3MFQAfGhEV0U5eK9J0tUviuEXg+mw3QFCu+Xw4kisR93873NQ9Tx
# TKk/tYuEr2Ty0BQhMYIERDCCBEACAQEwgZMwfzELMAkGA1UEBhMCVVMxHTAbBgNV
# BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVz
# dCBOZXR3b3JrMTAwLgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2Rl
# IFNpZ25pbmcgQ0ECEDPHur11WtvdILInrEv+uoUwCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFA7n
# 0hLkomCdU3cqTvy0jzDGcgJgMA0GCSqGSIb3DQEBAQUABIIBADd4xka0DOQetLZa
# yjtDeEHqAzz8+eb30kYkBC23ga+EW0hTlAgynaIAJTKhVNPn663P0jVjBMapYpOX
# rOa4DTsUbJb+ix3CxphbDjHLZjUVQ8FjZt/+jbN6qtVnAdWROG3HrV+fXFaMaxpA
# cTedc9OglkulzV2gXRE1aZaiIIJhwzolUHfMtIkNplVtFCFLEuE2SDfquYSDTS94
# W2p7o8EqMc1VcJJ58v2h8KMKWKa/VjJ+Yalrh81n+0Dja5KNnqLwJeXkuVZLIbH3
# bn4M7gnINKbSLklr/v+c7aKFTEkuEGDCGszvu94/HWmVulB38AR8HW77VfZZBjpg
# ZdK1l4ChggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5
# bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVu
# BNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMTgxMTI3MTAyMjI0WjAjBgkqhkiG9w0BCQQxFgQUWsV8
# eVfCY+GJQ9Tp/dKQewtB8hkwDQYJKoZIhvcNAQEBBQAEggEAKUsaMrtiIGkHFysn
# L6kR6iqCR/5mtTvQQVyu6WpgEutN0MI08JovizgxKyMmiVcGLrQttDehmGZRJqaO
# gf4u4KASs1uZ3EGVE1OCjZj9uPf/peMl0EE5X+kJX+Of6vmLpy33d5NhzhOIb1OI
# i0lSl4wTX91rzMJp7Ms2J09WFtdAin4prW+bhJUzIsYHFpTCJjWj7dCUcqkuwaYf
# r+hINdLQLsSYBzw/Q2GUM1ISz/7eD4M8p8EBvXptKXIma1Yq5dfIZQ86rcY8lbhm
# Eqs9jiJTXk0ImrE7bXfXBOXarbEbilFzAuHQ1aLzZQ7owN3kTfimpaWkKekuOBri
# mb/SDg==
# SIG # End signature block
