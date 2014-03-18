/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

include( 'main_sh.lua' );
AddCSLuaFile( 'main_sh.lua' );

-- force download the textures. 
resource.AddFile( 'materials/mc/texture_packs/default/dirt.vmt')
resource.AddFile( 'materials/mc/texture_packs/default/grass.vmt')
resource.AddFile( 'materials/mc/texture_packs/default/stone.vmt')



MsgC( Color(0,255,255),'----------- PMinecraft -----------\n');
local fileCount, lineCount, charCount, folderCount = 0, 0, 0, 0;
local function FCount( path )
	local files, folders = file.Find( path..'*', 'LUA' );
	fileCount = fileCount + #files;
	folderCount = folderCount + 1;

	for _, File in pairs( files )do
		local fc = file.Read( path..File, 'LUA' );
		charCount = charCount + string.len( fc );

		lineCount = lineCount + #string.Explode( '\n', fc );
	end

	for _, Dir in pairs( folders )do
		FCount( path..Dir..'/' );
	end
end

FCount( GM.FolderName .. '/gamemode/' );

print('PROJECT FILE SIZE: ');
print('files: ', fileCount );
print('line count: ', lineCount );
print('char count: ', charCount );
print('folder count: ', folderCount );
file.Write( 'pminecraft/project_stats.txt', string.format([[
NAME: %s
VERSION: %s
AUTHOR: %s

======= CODE ========
DIRECTORIES:      %s
FILES:            %s
TOTAL LINES:      %s
TOTAL CHARS:      %s

======= STATS =======
FILES/DIR:        %s
LINES/FILE:       %s
CHARS/LINE:       %s
CHARS/FILE:       %s
]], GM.Name, GM.Version, GM.Author, folderCount, fileCount, lineCount, charCount, math.Round(fileCount/folderCount), math.Round( lineCount/fileCount ), math.Round( charCount/lineCount ), math.Round( charCount/fileCount ) ) );


MsgC( Color(0,255,255),'----------------------------------\n');