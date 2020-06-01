using System;

namespace beef_utils
{
	public struct OSVersion
	{
#if BF_PLATFORM_WINDOWS
		private const String sVersionStr          = "{} (Version {}.{}, Build {}, {})";
		private const String sSPVersionStr        = "{} Service Pack {} (Version {}.{}, Build {}, {})";
		private const String sVersion32           = "32-bit Edition";
		private const String sVersion64           = "64-bit Edition";
		private const String sWindows             = "Windows";
		private const String sWindowsVista        = "Windows Vista";
		private const String sWindowsServer2008   = "Windows Server 2008";
		private const String sWindows7            = "Windows 7";
		private const String sWindowsServer2008R2 = "Windows Server 2008 R2";
		private const String sWindows2000         = "Windows 2000";
		private const String sWindowsXP           = "Windows XP";
		private const String sWindowsServer2003   = "Windows Server 2003";
		private const String sWindowsServer2003R2 = "Windows Server 2003 R2";
		private const String sWindowsServer2012   = "Windows Server 2012";
		private const String sWindowsServer2012R2 = "Windows Server 2012 R2";
		private const String sWindowsServer2016   = "Windows Server 2016";
		private const String sWindows8            = "Windows 8";
		private const String sWindows8Point1      = "Windows 8.1";
		private const String sWindows10           = "Windows 10";

		private const uint8 VER_PRODUCT_TYPE     = 0x00000080;
		private const uint8 VER_NT_WORKSTATION   = 0x00000001;
														    
		[CRepr]
		struct TOSVersionInfoA {
			public uint32 DwOSVersionInfoSize;
			public uint32 DwMajorVersion;
			public uint32 DwMinorVersion;
			public uint32 DwBuildNumber;
			public uint32 DwPlatformId;
			public uint8[128] SzCSDVersion; // Maintenance UnicodeString for PSS usage

		}
		[CRepr]
		struct TOSVersionInfoW {
			public uint32 DwOSVersionInfoSize;
			public uint32 DwMajorVersion;
			public uint32 DwMinorVersion;
			public uint32 DwBuildNumber;
			public uint32 DwPlatformId;
			public uint16[128] SzCSDVersion; // Maintenance UnicodeString for PSS usage

		}
		typealias TOSVersionInfo = TOSVersionInfoW;
		[CRepr]
		struct TOSVersionInfoExA : TOSVersionInfoA {
			public uint16 WServicePackMajor;
			public uint16 WServicePackMinor;
			public uint16 WSuiteMask;
			public uint8 WProductType;
			public uint8 WReserved;
		}
		[CRepr]
		struct TOSVersionInfoExW : TOSVersionInfoW
		{
			public uint16 WServicePackMajor;
			public uint16 WServicePackMinor;
			public uint16 WSuiteMask;
			public uint8 WProductType;
			public uint8 WReserved;
		}
		typealias TOSVersionInfoEx = TOSVersionInfoExW;

		[CRepr]
		struct TSystemInfo {
			public uint16 WProcessorArchitecture;
			public uint16 WReserved;
			public uint32 DwPageSize;
			public void* LpMinimumApplicationAddress;
			public void* LpMaximumApplicationAddress;
			public uint32* DwActiveProcessorMask;
			public uint32 DwNumberOfProcessors;
			public uint32 DwProcessorType;
			public uint32 DwAllocationGranularity;
			public uint16 WProcessorLevel;
			public uint16 WProcessorRevision;
		}
		
		[CRepr]
		struct WKSTA_INFO_100
		{
			public uint32 wki100_platform_id;
			public uint32 wki100_computername;
			public uint32 wki100_langroup;
			public uint32 wki100_ver_major;
			public uint32 wki100_ver_minor;
		}
		typealias LPWKSTA_INFO_100 = WKSTA_INFO_100*;

		[CRepr]
		struct TVSFixedFileInfo
		{
			public uint32 dwSignature;        // e.g. $feef04bd
			public uint32 dwStrucVersion;     // e.g. $00000042 = "0.42"
			public uint32 dwFileVersionMS;    // e.g. $00030075 = "3.75"
			public uint32 dwFileVersionLS;    // e.g. $00000031 = "0.31"
			public uint32 dwProductVersionMS; // e.g. $00030010 = "3.10"
			public uint32 dwProductVersionLS; // e.g. $00000031 = "0.31"
			public uint32 dwFileFlagsMask;    // = $3F for version "0.42"
			public uint32 dwFileFlags;        // e.g. VFF_DEBUG | VFF_PRERELEASE
			public uint32 dwFileOS;           // e.g. VOS_DOS_WINDOWS16
			public uint32 dwFileType;         // e.g. VFT_DRIVER
			public uint32 dwFileSubtype;      // e.g. VFT2_DRV_KEYBOARD
			public uint32 dwFileDateMS;       // e.g. 0
			public uint32 dwFileDateLS;       // e.g. 0
		}
		typealias PVSFixedFileInfo = TVSFixedFileInfo*;
#elif BF_PLATFORM_LINUX
			outVar.AppendF(sVersionStr, fPrettyName, fName, fMajor, fMinor, fServicePackMajor);
		private const String sVersionStr = "{} {} (Version {}.{}.{})";
#else // MACOS and ANDROID
			outVar.AppendF(sVersionStr, fName, fMajor, fMinor, fServicePackMajor);
		private const String sVersionStr = "{} (Version {}.{}.{})";
#endif

		public enum TArchitecture
		{
			X86,
			X64,
			ARM32,
			ARM64
		}

		public enum TPlatform
		{
			Windows,
			MacOS,
			iOS,
			Android,
			Linux
		}

		private static TArchitecture fArchitecture;
		private static uint fBuild;
		private static uint fMajor;
		private static uint fMinor;
		private static String fName;
    	private static TPlatform fPlatform;
    	private static uint fServicePackMajor;
    	private static uint fServicePackMinor;
		#if BF_PLATFORM_LINUX
			private static String fPrettyName;
			private static uint fLibCVersionMajor;
			private static uint fLibCVersionMinor;
		#endif

		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static bool GetVersionExA(TOSVersionInfoA* lpVersionInformation);
		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static bool GetVersionExW(TOSVersionInfoW* lpVersionInformation);
		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static bool GetVersionExA(TOSVersionInfoExA* lpVersionInformation);
		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static bool GetVersionExW(TOSVersionInfoExW* lpVersionInformation);

		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static bool VerifyVersionInfoA(TOSVersionInfoEx* lpVersionInformation, uint32 dwTypeMask, uint64 dwlConditionMask);
		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static bool VerifyVersionInfoW(TOSVersionInfoEx* lpVersionInformation, uint32 dwTypeMask, uint64 dwlConditionMask);

		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static uint64 VerSetConditionMask(uint64 dwlConditionMask, uint32 dwTypeBitMask, uint8 dwConditionMask);

		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static void GetNativeSystemInfo(TSystemInfo* lpSystemInformation);
		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static void GetSystemInfo(TSystemInfo* lpSystemInfo);

		[Import("netapi32.lib"), CLink, StdCall]
		private extern static uint32 NetWkstaGetInfo(char16* ServerName, uint32 Level, out LPWKSTA_INFO_100 BufPtr);
		[Import("netapi32.lib"), CLink, StdCall]
		private extern static int32 NetApiBufferFree(LPWKSTA_INFO_100 BufPtr);

		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static uint32 GetFileVersionInfoSizeA(char8* lptstrFilename, uint32* lpdwHandle);
		[Import("Kernel32.lib"), CLink, StdCall]
		private extern static uint32 GetFileVersionInfoSizeW(char16* lptstrFilename, uint32* lpdwHandle);

		[Import("Version.lib"), CLink, StdCall]
		private extern static bool GetFileVersionInfoA(char8* lptstrFilename, out uint32 dwHandle, uint32 dwLen, void* lpData);
		[Import("Version.lib"), CLink, StdCall]
		private extern static bool GetFileVersionInfoW(char16* lptstrFilename, out uint32 dwHandle, uint32 dwLen, void* lpData);
		[Import("Version.lib"), CLink, StdCall]
		private extern static bool VerQueryValueA(void* pBlock, char8* lpSubBlock, void** lplpBuffer, out uint32 puLen);
		[Import("Version.lib"), CLink, StdCall]
		private extern static bool VerQueryValueW(void* pBlock, char16* lpSubBlock, void** lplpBuffer, out uint32 puLen);

		[Import("User32.lib"), CLink, StdCall]
		private extern static int GetSystemMetrics(int nIndex);

		public static this()
		{
#if BF_PLATFORM_WINDOWS
			bool isWinSrv()
			{
				TOSVersionInfoEx osvi = .();
				uint64 dwlCondMask;

				osvi.WProductType = VER_NT_WORKSTATION;

				dwlCondMask = VerSetConditionMask(0, VER_PRODUCT_TYPE, 1 /* VER_EQUAL */);

				return VerifyVersionInfoW(&osvi, VER_PRODUCT_TYPE, dwlCondMask) == false;
			}

			bool GetProductVersion(String filename, out uint32 major, out uint32 minor, out uint32 build)
			{
				bool result = false;
				major       = 0;
				minor       = 0;
				build       = 0;
				uint32 VerSize, Wnd;
				PVSFixedFileInfo FI = &TVSFixedFileInfo();

				uint32 InfoSize = GetFileVersionInfoSizeA(filename.CStr(), &Wnd);

				if (InfoSize != 0) {
					void* VerBuf = Internal.StdMalloc(InfoSize);

					if (GetFileVersionInfoA(filename.CStr(), out Wnd, InfoSize, VerBuf)) {
						if (VerQueryValueA(VerBuf, "\\", (void**)(&FI), out VerSize)) {
							major = FI.dwProductVersionMS >> 16;
							minor = (uint16)FI.dwProductVersionMS;
							build = FI.dwProductVersionLS >> 16;
							result = true;
						}
					}

					Internal.StdFree(VerBuf);
				}
 
				return result;
			}

			bool GetNetWkstaMajorMinor(out uint32 major, out uint32 minor)
			{
				LPWKSTA_INFO_100 LBuf = ?;
				bool result = NetWkstaGetInfo(null, 100, out LBuf) == 0;

				if (result) {
				    major = LBuf.wki100_ver_major;
				    minor = LBuf.wki100_ver_minor;
				} else {
				    major = 0;
				    minor = 0;
				}

				if (LBuf != null)
					NetApiBufferFree(LBuf);

				return result;
			}

			TSystemInfo SysInfo = .();
			TOSVersionInfoEx VerInfo = .();
			uint32 MajorNum, MinorNum, BuildNum;

			VerInfo.DwOSVersionInfoSize = sizeof(TOSVersionInfoEx);
			GetVersionExW(&VerInfo);

			fPlatform         = .Windows;
			fMajor            = VerInfo.DwMajorVersion;
			fMinor            = VerInfo.DwMinorVersion;
			fBuild            = VerInfo.DwBuildNumber;
			fServicePackMajor = VerInfo.WServicePackMajor;
			fServicePackMinor = VerInfo.WServicePackMinor;

			if (Check(5, 1)) // GetNativeSystemInfo not supported on Windows 2000
				GetNativeSystemInfo(&SysInfo);

			fArchitecture = SysInfo.WProcessorArchitecture == 9 /* PROCESSOR_ARCHITECTURE_AMD64 */ ? .X64 : .X86;

			if ((fMajor > 6) || ((fMajor == 6) && (fMinor > 1))) {
			  	if (GetProductVersion("kernel32.dll", out MajorNum, out MinorNum, out BuildNum)) {
				    fMajor = MajorNum;
				    fMinor = MinorNum;
				    fBuild = BuildNum;
				} else if (GetNetWkstaMajorMinor(out MajorNum, out MinorNum)) {
			    	fMajor = MajorNum;
			    	fMinor = MinorNum;
			  	}
			}

			fName = sWindows;

			switch(fMajor) {
			case 10:
				switch(fMinor) {
				case 0: fName = !isWinSrv() ? sWindows10 : sWindowsServer2016;
					// Server 2019 is also 10.0
				}
				break;
			case 6:
				switch(fMinor) {
				case 0: fName = VerInfo.WProductType == VER_NT_WORKSTATION ? sWindowsVista : sWindowsServer2008;
				case 1: fName = VerInfo.WProductType == VER_NT_WORKSTATION ? sWindows7 : sWindowsServer2008R2;
				case 2: fName = VerInfo.WProductType == VER_NT_WORKSTATION ? sWindows8 : sWindowsServer2012;
				case 3: fName = !isWinSrv() ? sWindows8Point1 : sWindowsServer2012R2;
				}
				break;
			case 5:
				switch(fMinor) {
				case 0: fName = sWindows2000;
				case 1: fName = sWindowsXP;
				case 2:
					{
						if ((VerInfo.WProductType == VER_NT_WORKSTATION) &&
							(SysInfo.WProcessorArchitecture == 9 /* PROCESSOR_ARCHITECTURE_AMD64 */)) {
							fName = sWindowsXP;
						} else {
							fName = GetSystemMetrics(89 /* SM_SERVERR2 */) == 0 ? sWindowsServer2003 : sWindowsServer2003R2;
						}
					}
				}
				break;
			}
#endif
		}
		
		[Inline]
		public static bool Check(uint major)
		{
			return fMajor == major;
		}
		
		[Inline]
		public static bool Check(uint major, uint minor)
		{
			return (fMajor > major) || ((fMajor == major) && (fMinor >= minor));
		}

		[Inline]
		public static bool Check(uint major, uint minor, uint svcPackMajor)
		{
			return (fMajor > major) || ((fMajor == major) && (fMinor > minor)) ||
    			((fMajor == major) && (fMinor == minor) && (fServicePackMajor >= svcPackMajor));
		}

		[Inline]
		public static bool Check(uint major, uint minor, uint svcPackMajor, uint svcPackMinor)
		{
			return (fMajor > major) || ((fMajor == major) && (fMinor > minor)) ||
    			((fMajor == major) && (fMinor == minor) && (fServicePackMajor > svcPackMajor)) ||
    			((fMajor == major) && (fMinor == minor) && (fServicePackMajor == svcPackMajor) && (fServicePackMinor >= svcPackMinor));
		}

		public override void ToString(String outVar)
		{
			#if BF_PLATFORM_WINDOWS
				String arch = fArchitecture == .X86 ? sVersion32 : sVersion64;
	
				if (fServicePackMajor == 0) {
					outVar.AppendF(sVersionStr, fName, fMajor, fMinor, fBuild, arch);
				} else {
					outVar.AppendF(sSPVersionStr, fName, fServicePackMajor, fMajor, fMinor, fBuild, arch);
				}
			#elif BF_PLATFORM_LINUX
				outVar.AppendF(sVersionStr, fPrettyName, fName, fMajor, fMinor, fServicePackMajor);
			#else // MACOS and ANDROID
				outVar.AppendF(sVersionStr, fName, fMajor, fMinor, fServicePackMajor);
			#endif
		}

		public TArchitecture Architecture()
		{
			return fArchitecture;
		}

		public uint Build()
		{
			return fBuild;
		}

		public uint Major()
		{
			return fMajor;
		}

		public uint Minor()
		{
			return fMinor;
		}

		public void Name(String outVal)
		{
			outVal.Clear();
			outVal.Append(fName);
		}

		public TPlatform Platform()
		{
			return fPlatform;
		}

		public uint ServicePackMajor()
		{
			return fServicePackMajor;
		}

		public uint ServicePackMinor()
		{
			return fServicePackMinor;
		}

		#if BF_PLATFORM_LINUX
			public void PrettyName(String outVal)
			{
				outVal.Clear();
				outVal.Append(fPrettyName);
			}

			public uint LibCVersionMajor()
			{
				return fLibCVersionMajor;
			}

			public uint LibCVersionMinor()
			{
				return fLibCVersionMinor;
			}
		#endif
	}
}
