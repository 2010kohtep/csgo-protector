unit SourceSDK;

interface

uses
  Types;

// I'm lazy ass, so some classes and variables will be defined as "Pointer" in function arguments
// <! [!] !> The module is very and very raw, so here can be errors!

{$A4}
{$Z4}

// const.h
const
 STEAM_PARM: PAnsiChar = '-steam';
 AUTO_RESTART: PAnsiChar = '-autoupdate';

 INVALID_STEAM_TICKET: PAnsiChar = 'Invalid STEAM UserID Ticket'#10;
 INVALID_STEAM_LOGON: PAnsiChar = 'No Steam logon'#10;
 INVALID_STEAM_VACBANSTATE: PAnsiChar = 'VAC banned from secure server'#10;
 INVALID_STEAM_LOGGED_IN_ELSEWHERE: PAnsiChar = 'This Steam account is being used in another location'#10;

 DEFAULT_TICK_INTERVAL = 0.015;
 MINIMUM_TICK_INTERVAL = 0.001;
 MAXIMUM_TICK_INTERVAL = 0.1;

 ABSOLUTE_PLAYER_LIMIT = 255;
 ABSOLUTE_PLAYER_LIMIT_DW = ABSOLUTE_PLAYER_LIMIT div 32 + 1;

 MAX_PLAYER_NAME_LENGTH = 32;

 MAX_PLAYERS_PER_CLIENT = 1;

 MAX_MAP_NAME = 32;
 MAX_NETWORKID_LENGTH = 64;

 SP_MODEL_INDEX_BITS = 11;

 MAX_EDICT_BITS = 11;
 MAX_EDICTS = 1 shl MAX_EDICT_BITS;

 MAX_SERVER_CLASS_BITS = 9;
 MAX_SERVER_CLASSES = 1 shl MAX_SERVER_CLASS_BITS;

 SIGNED_GUID_LEN = 32;

 NUM_ENT_ENTRY_BITS = MAX_EDICT_BITS + 1;
 NUM_ENT_ENTRIES = 1 shl NUM_ENT_ENTRY_BITS;
 ENT_ENTRY_MASK = NUM_ENT_ENTRIES - 1;
 INVALID_EHANDLE_INDEX = $FFFFFFFF;

 NUM_SERIAL_NUM_BITS = 32 - NUM_ENT_ENTRY_BITS;

 NUM_NETWORKED_EHANDLE_SERIAL_NUMBER_BITS = 10;
 NUM_NETWORKED_EHANDLE_BITS = MAX_EDICT_BITS + NUM_NETWORKED_EHANDLE_SERIAL_NUMBER_BITS;
 INVALID_NETWORKED_EHANDLE_VALUE = (1 shl NUM_NETWORKED_EHANDLE_BITS) - 1;

 MAX_PACKEDENTITY_DATA = $4000;

 MAX_PACKEDENTITY_PROPS = $1000;

 MAX_CUSTOM_FILES = 4;
 MAX_CUSTOM_FILE_SIZE = $20000;

 FL_ONGROUND = 1 shl 0;
 FL_DUCKING = 1 shl 1;
 FL_WATERJUMP = 1 shl 2;
 FL_ONTRAIN = 1 shl 3;
 FL_INRAIN = 1 shl 4;
 FL_FROZEN = 1 shl 5;
 FL_ATCONTROLS = 1 shl 6;
 FL_CLIENT = 1 shl 7;
 FL_FAKECLIENT = 1 shl 8;

 PLAYER_FLAG_BITS = 9;

 FL_INWATER = 1 shl 9;
 FL_FLY = 1 shl 10;
 FL_SWIM = 1 shl 11;
 FL_CONVEYOR = 1 shl 12;
 FL_NPC = 1 shl 13;
 FL_GODMODE = 1 shl 14;
 FL_NOTARGET = 1 shl 15;
 FL_AIMTARGET = 1 shl 16;
 FL_PARTIALGROUND = 1 shl 17;
 FL_STATICPROP = 1 shl 18;
 FL_GRAPHED = 1 shl 19;
 FL_GRENADE = 1 shl 20;
 FL_STEPMOVEMENT = 1 shl 21;
 FL_DONTTOUCH = 1 shl 22;
 FL_BASEVELOCITY = 1 shl 23;
 FL_WORLDBRUSH = 1 shl 24;
 FL_OBJECT = 1 shl 25;
 FL_KILLME = 1 shl 26;
 FL_ONFIRE = 1 shl 27;
 FL_DISSOLVING = 1 shl 28;
 FL_TRANSRAGDOLL = 1 shl 29;
 FL_UNBLOCKABLE_BY_PLAYER = 1 shl 30;

type
 MoveType_t = (MOVETYPE_NONE = 0,
               MOVETYPE_ISOMETRIC,
               MOVETYPE_WALK,
               MOVETYPE_STEP,
               MOVETYPE_FLY,
               MOVETYPE_FLYGRAVITY,
               MOVETYPE_VPHYSICS,
               MOVETYPE_PUSH,
               MOVETYPE_NOCLIP,
               MOVETYPE_LADDER,
               MOVETYPE_OBSERVER,
               MOVETYPE_CUSTOM,

               MOVETYPE_LAST = MOVETYPE_CUSTOM,

               MOVETYPE_MAX_BITS = 4);

type
 MoveCollide_t = (MOVECOLLIDE_DEFAULT = 0,

                  MOVECOLLIDE_FLY_BOUNCE,
                  MOVECOLLIDE_FLY_CUSTOM,
                  MOVECOLLIDE_FLY_SLIDE,

                  MOVECOLLIDE_COUNT,

                  MOVECOLLIDE_MAX_BITS = 3);

type
 SolidType_t = (SOLID_NONE = 0,
                SOLID_BSP	= 1,
                SOLID_BBOX = 2,
                SOLID_OBB = 3,
                SOLID_OBB_YAW = 4,
                SOLID_CUSTOM = 5,
                SOLID_VPHYSICS = 6,
                SOLID_LAST);

type
 SolidFlags_t = (FSOLID_CUSTOMRAYTEST = $0001,
                 FSOLID_CUSTOMBOXTEST = $0002,
                 FSOLID_NOT_SOLID = $0004,
                 FSOLID_TRIGGER = $0008,

                 FSOLID_NOT_STANDABLE = $0010,
                 FSOLID_VOLUME_CONTENTS = $0020,
                 FSOLID_FORCE_WORLD_ALIGNED = $0040,
                 FSOLID_USE_TRIGGER_BOUNDS = $0080,
                 FSOLID_ROOT_PARENT_ALIGNED = $0100,
                 FSOLID_TRIGGER_TOUCH_DEBRIS = $0200);

const
 FSOLID_MAX_BITS = 10;

 LIFE_ALIVE = 0;
 LIFE_DYING = 1;
 LIFE_DEAD = 2;
 LIFE_RESPAWNABLE = 3;
 LIFE_DISCARDBODY = 4;

 EF_BONEMERGE = $001;
 EF_BRIGHTLIGHT = $002;
 EF_DIMLIGHT = $004;
 EF_NOINTERP = $008;
 EF_NOSHADOW = $010;
 EF_NODRAW = $020;
 EF_NORECEIVESHADOW = $040;
 EF_BONEMERGE_FASTCULL = $080;

 EF_ITEM_BLINK = $100;
 EF_PARENT_ANIMATES = $200;

 EF_MAX_BITS = 10;

 EF_PARITY_BITS = 3;
 EF_PARITY_MASK = (1 shl EF_PARITY_BITS) - 1;

 EF_MUZZLEFLASH_BITS = 2;

 PLAT_LOW_TRIGGER = 1;

 SF_TRAIN_WAIT_RETRIGGER = 1;
 SF_TRAIN_PASSABLE = 8;

 FIXANGLE_NONE = 0;
 FIXANGLE_ABSOLUTE = 1;
 FIXANGLE_RELATIVE = 2;

 BREAK_GLASS = $01;
 BREAK_METAL = $02;
 BREAK_FLESH = $04;
 BREAK_WOOD = $08;

 BREAK_SMOKE = $10;
 BREAK_TRANS = $20;
 BREAK_CONCRETE = $40;

 BREAK_SLAVE = $80;

 BOUNCE_GLASS = BREAK_GLASS;
 BOUNCE_METAL = BREAK_METAL;
 BOUNCE_FLESH = BREAK_FLESH;
 BOUNCE_WOOD = BREAK_WOOD;
 BOUNCE_SHRAP = $10;
 BOUNCE_SHELL = $20;
 BOUNCE_CONCRETE = BREAK_CONCRETE;
 BOUNCE_SHOTSHELL = $80;

 TE_BOUNCE_NULL = 0;
 TE_BOUNCE_SHELL = 1;
 TE_BOUNCE_SHOTSHELL = 2;

type
 RenderMode_t = (kRenderNormal,
                 kRenderTransColor,
                 kRenderTransTexture,
                 kRenderGlow,
                 kRenderTransAlpha,
                 kRenderTransAdd,
                 kRenderEnvironmental,
                 kRenderTransAddFrameBlend,
                 kRenderTransAlphaAdd,
                 kRenderWorldGlow,
                 kRenderNone);

type
 RenderFx_t = (kRenderFxNone = 0,
               kRenderFxPulseSlow,
               kRenderFxPulseFast,
               kRenderFxPulseSlowWide,
               kRenderFxPulseFastWide,
               kRenderFxFadeSlow,
               kRenderFxFadeFast,
               kRenderFxSolidSlow,
               kRenderFxSolidFast,
               kRenderFxStrobeSlow,
               kRenderFxStrobeFast,
               kRenderFxStrobeFaster,
               kRenderFxFlickerSlow,
               kRenderFxFlickerFast,
               kRenderFxNoDissipation,
               kRenderFxDistort,
               kRenderFxHologram,
               kRenderFxExplode,
               kRenderFxGlowShell,
               kRenderFxClampMinScale,
               kRenderFxEnvRain,
               kRenderFxEnvSnow,
               kRenderFxSpotlight,
               kRenderFxRagdoll,
               kRenderFxPulseFastWider,
               kRenderFxMax);

type
 Collision_Group_t = (COLLISION_GROUP_NONE = 0,
                      COLLISION_GROUP_DEBRIS,
                      COLLISION_GROUP_DEBRIS_TRIGGER,
                      COLLISION_GROUP_INTERACTIVE_DEBRIS,
                      COLLISION_GROUP_INTERACTIVE,
                      COLLISION_GROUP_PLAYER,
                      COLLISION_GROUP_BREAKABLE_GLASS,
                      COLLISION_GROUP_VEHICLE,                                       
                      COLLISION_GROUP_PLAYER_MOVEMENT,

                      COLLISION_GROUP_NPC,
                      COLLISION_GROUP_IN_VEHICLE,
                      COLLISION_GROUP_WEAPON,
                      COLLISION_GROUP_VEHICLE_CLIP,
                      COLLISION_GROUP_PROJECTILE,
                      COLLISION_GROUP_DOOR_BLOCKER,
                      COLLISION_GROUP_PASSABLE_DOOR,
                      COLLISION_GROUP_DISSOLVING,
                      COLLISION_GROUP_PUSHAWAY,

                      COLLISION_GROUP_NPC_ACTOR,
                      COLLISION_GROUP_NPC_SCRIPTED,

                      LAST_SHARED_COLLISION_GROUP);

const
 SOUND_NORMAL_CLIP_DIST = 1000.0;

 MAX_AREA_STATE_BYTES = 32;
 MAX_AREA_PORTAL_STATE_BYTES = 24;

 MAX_USER_MSG_DATA = 255;
 MAX_ENTITY_MSG_DATA = 255;

function IsSolid(SolidType: SolidType_t; nSolidFlags: LongInt): Boolean;

const
  SOUND_SEQNUMBER_BITS = 10;
  SOUND_SEQNUMBER_MASK = (1 shl SOUND_SEQNUMBER_BITS) - 1;
  SOUND_DELAY_OFFSET = 100.0;

// soundflags.h
type
  TChannels = (CHAN_REPLACE = -1,
               CHAN_AUTO = 0,
               CHAN_WEAPON = 1,
               CHAN_VOICE = 2,
               CHAN_ITEM = 3,
               CHAN_BODY = 4,
               CHAN_STREAM = 5,
               CHAN_STATIC = 6,
               CHAN_VOICE_BASE = 7,
               CHAN_USER_BASE = CHAN_VOICE_BASE + 128);

  soundlevel_p = ^soundlevel_t;
  soundlevel_t =
  (SNDLVL_NONE = 0,

  SNDLVL_20dB = 20,
  SNDLVL_25dB = 25,
  SNDLVL_30dB = 30,
  SNDLVL_35dB = 35,
  SNDLVL_40dB = 40,
  SNDLVL_45dB = 45,

  SNDLVL_50dB = 50,
  SNDLVL_55dB = 55,

  SNDLVL_IDLE = 60,
  SNDLVL_60dB = 60,

  SNDLVL_65dB = 65,
  SNDLVL_STATIC = 66,

  SNDLVL_70dB = 70,

  SNDLVL_NORM = 75,
  SNDLVL_75dB = 75,

  SNDLVL_80dB = 80,
  SNDLVL_TALKING = 80,
  SNDLVL_85dB = 85,
  SNDLVL_90dB = 90,
  SNDLVL_95dB = 95,
  SNDLVL_100dB = 100,
  SNDLVL_105dB = 105,
  SNDLVL_110dB = 110,
  SNDLVL_120dB = 120,
  SNDLVL_130dB = 130,

  SNDLVL_GUNFIRE = 140,
  SNDLVL_140dB = 140,

  SNDLVL_150dB = 150,

  SNDLVL_180dB = 180);

  SoundFlags_p = ^SoundFlags_t;
  SoundFlags_t =  (SND_NOFLAGS = 0, // TODO: set of
                         SND_CHANGE_VOL = 1 shl 0,
                         SND_CHANGE_PITCH = 1 shl 1,
                         SND_STOP = 1 shl 2,
                         SND_SPAWNING = 1 shl 3,

                         SND_DELAY = 1 shl 4,
                         SND_STOP_LOOPING = 1 shl 5,
                         SND_SPEAKER = 1 shl 6,

                         SND_SHOULDPAUSE = 1 shl 7,
                         SND_IGNORE_PHONEMES = 1 shl 8,
                         SND_IGNORE_NAME = 1 shl 9);

const
  VOL_NORM = 1.0;

  ATTN_NONE = 0.0;
  ATTN_NORM = 0.8;
  ATTN_IDLE = 2.0;
  ATTN_STATIC = 1.25;
  ATTN_RICOCHET = 1.5;

  ATTN_GUNFIRE = 0.27;

  PITCH_NORM = 100;
  PITCH_LOW = 95;
  PITCH_HIGH = 120;

  DEFAULT_SOUND_PACKET_VOLUME = 1.0;
  DEFAULT_SOUND_PACKET_PITCH = 100;
  DEFAULT_SOUND_PACKET_DELAY = 0.0;

  MAX_SNDLVL_BITS = 9;
  MIN_SNDLVL_VALUE = 0;
  MAX_SNDLVL_VALUE = (1 shl MAX_SNDLVL_BITS) - 1;

  MAX_ATTENUATION = 3.98;

  SND_FLAG_BITS_ENCODE = 9;

  MAX_SOUND_INDEX_BITS = 13;
  MAX_SOUNDS = 1 shl MAX_SOUND_INDEX_BITS;

  MAX_SOUND_DELAY_MSEC_ENCODE_BITS = 13;

  MAX_SOUND_DELAY_MSEC = 1 shl (MAX_SOUND_DELAY_MSEC_ENCODE_BITS - 1);

type
  SpatialPartitionHandle_t = Word;
  SpatialPartitionListMask_t = LongInt;
  SpatialTempHandle_t = LongInt;

  IterationRetval_t = (ITERATION_CONTINUE = 0, ITERATION_STOP);

type
  size_t = LongWord;

// cmd.cpp
const
  CMDSTR_ADD_EXECUTION_MARKER: PAnsiChar = '[$&*,`]';

  MAX_ALIAS_NAME = 32;
  MAX_COMMAND_LENGTH = 1024;

type
  cmdalias_p = ^cmdalias_t;
  cmdalias_t = record
    Next: cmdalias_p;
    Name: array[0..MAX_ALIAS_NAME - 1] of AnsiChar;
    Value: PAnsiChar;
  end;

// dbg.h
const
  SPEW_TYPE_COUNT = 5;

type
  SpewType_t = (SPEW_MESSAGE = 0, SPEW_WARNING, SPEW_ASSERT, SPEW_ERROR, SPEW_LOG);
  SpewRetval_t = (SPEW_DEBUGGER = 0, SPEW_CONTINUE, SPEW_ABORT);

// imageformat.h
type
  RGB888_t = record
    R, G, B: Byte;
  end;

  BGR888_t = record
    B, G, R: Byte;
  end;

  RGBA8888_t = record
    R, G, B, A: Byte;
  end;

  BGRA8888_t = record
    B, G, R, A: Byte;
  end;

// render.h
type
  PIRender = ^IRender;
  IRender = record
    FrameBegin: procedure; stdcall;
    FrameEnd: procedure; stdcall;

    
  end;

// interface.h
type
  PCreateInterfaceFn = ^CreateInterfaceFn;
  CreateInterfaceFn = function(Name: PAnsiChar; Error: PBoolean = nil): Pointer; cdecl;

type
  PIBaseInterface = ^IBaseInterface;
  IBaseInterface = record
    Destroy: procedure(B: Boolean); stdcall;
  end;

// color.h
type
 PColor = ^TColor;
 TColor = class

 end;

// bsptreedata.h
type
 PISpatialLeafEnumerator = ^ISpatialLeafEnumerator;
 ISpatialLeafEnumerator = record
  EnumerateLeaf: function(Leaf: LongInt; Context: LongInt): Boolean; cdecl;
 end;

// ??? (vector)

type
 PVector = ^Vector;
 Vector = record
  X, Y, Z: Single;
 end;

// cache_user.h
type
 cache_user_s = ^cache_user_t;
 cache_user_t = record
  Data: Pointer;
 end;

// soundinfo.h
type
  SoundInfo_p = ^SoundInfo_t;
  SoundInfo_t = record
    SequenceNumber, // 0
    EntityIndex, // 4
    Channel: LongInt; // 8
    Name: PAnsiChar; // 12
    Origin, // 16
    Direction: Vector; // 28
    Volume: Single; // 40
    SoundLevel: soundlevel_t; // 44
    Looping: Boolean; // 48
    Pitch: LongInt; // 52
    ListenerOrigin: Vector; // 56
    Flags: LongInt; // 68
    SoundNum: LongInt; // 72
    Delay: Single; // 76
    IsSentence, // 80
    IsAmbient: Boolean; // 84
    SpeakerEntity: LongInt; // 88
  end;

// qlimits.h

const
 MAX_NUM_ARGVS = 50;
 MAX_QPATH = 64;
 MAX_OSPATH = 260;

 ON_EPSILON = 0.1;

 MAX_LIGHTSTYLE_INDEX_BITS = 6;
 MAX_LIGHTSTYLES = 1 shl MAX_LIGHTSTYLE_INDEX_BITS;

 MAX_MODEL_INDEX_BITS = 9;
 MAX_MODELS = 1 shl MAX_MODEL_INDEX_BITS;

 MAX_GENERIC_INDEX_BITS = 9;
 MAX_GENERIC = 1 shl MAX_GENERIC_INDEX_BITS;
 MAX_DECAL_INDEX_BITS = 9;
 MAX_BASE_DECALS = 1 shl MAX_DECAL_INDEX_BITS;

// mathlib.h
type
  PColorRGBExp32 = ^ColorRGBExp32;
  ColorRGBExp32 = record
    R, G, B: Byte;
    Exponent: Byte // ?
  end;

type
 cplane_s = ^cplane_t;
 cplane_t = record
  Normal: Vector;
  Dist: Single;
  PlaneType: Byte;
  SignBits: Byte;
  Pad: array[1..2] of Byte;
 end;

// dlight.h
type
  DLightStyle = set of (DLIGHT_NO_WORLD_ILLUMINATION = $1,
                        DLIGHT_NO_MODEL_ILLUMINATION = $2,
                        DLIGHT_ADD_DISPLACEMENT_ALPHA = $4,
                        DLIGHT_SUBTRACT_DISPLACEMENT_ALPHA = $8,
                        DLIGHT_DISPLACEMENT_MASK = $4 or $8);


 dlight_t = record
   Flags: LongInt;
   Origin: Vector;
   Radius: Single;
   Color: ColorRGBExp32;
 end;

// model_types.h
const
 STUDIO_NONE                     = $00000000;
 STUDIO_RENDER                   = $00000001;
 STUDIO_VIEWXFORMATTACHMENTS     = $00000002;
 STUDIO_DRAWTRANSLUCENTSUBMODELS = $00000004;
 STUDIO_FRUSTUMCULL              = $00000008;
 STUDIO_TWOPASS                  = $00000010;
 STUDIO_STATIC_LIGHTING          = $00000020;
 STUDIO_OCCLUSIONCULL            = $00000040;
 STUDIO_TRANSPARENCY             = $80000000;

type
 modtype_t = (mod_bad = 0, mod_brush, mod_sprite, mod_studio);

// hud.h
 wrect_s = ^wrect_t;
 wrect_t = record
  Left, Right, Top, Bottom: LongInt;
 end;

// enginesprite.h
type
 CEngineSprite = record
  GetWidth: function: LongInt; stdcall;
  GetHeight: function: LongInt; stdcall;
  GetNumFrames: function: LongInt; stdcall;
  // IMaterial
  GetMaterial: function: Pointer; stdcall;
  Init: function(const Name: PAnsiChar): Boolean; stdcall;
  Shutdown: procedure; stdcall;
  UnloadMaterial: procedure; stdcall;
  SetColor: procedure(R, G, B: Single); stdcall;
  SetAdditive: procedure(Enable: Boolean); stdcall;
  SetFrame: procedure(Frame: Single); stdcall;
  SetRenderMode: procedure(RenderMode: LongInt); stdcall;
  GetOrientation: function: LongInt; stdcall;
  GetHUDSpriteColor: procedure(Color: PSingle); stdcall;
  GetUp: function: Single; stdcall;
  GetDown: function: Single; stdcall;
  GetLeft: function: Single; stdcall;
  GetRight: function: Single; stdcall;
  DrawFrame: procedure(Frame: LongInt; X, Y: LongInt; SubRect: wrect_s); stdcall;
  DrawFrameOfSize: procedure(Frame: LongInt; X, Y: LongInt; Widht, Height: LongInt; SubRect: wrect_s); stdcall;
  IsAVI: function: Boolean; stdcall;
  IsBIK: function: Boolean; stdcall;
  GetTexCoordRange: procedure(MinU, MinV, MaxU, MaxV: PSingle); stdcall;
 end;

// gl_model_private.h (NOT FULL)
// TODO: brushdata_t pointer fix
type
 mnode_s = ^mnode_t;
 mnode_t = record
  Area: SmallInt;

  Contents: LongInt;
  VisFrame: LongInt;
  m_vecCenter: Vector;
  m_vecHalfDiagonal: Vector;
  Parent: mnode_s;

  Plane: cplane_s;
  Children: mnode_s;

  FirstSurface: Word;
  NumSurfaces: Word;
 end;


type
 mmodel_s = ^mmodel_t;
 mmodel_t = record
  Mins, Maxs: Vector;
  Origin: Vector;
  Radius: Single;
  Headnode: LongInt;
  Visleafs: LongInt;
  Firstface: LongInt;
  Numfaces: LongInt
 end;

 brushdata_s = ^brushdata_t;
 brushdata_t = record
  FirstModelSurface: LongInt;

  NumModelSurfaces: LongInt;
  SubModels: mmodel_s;

  NumPlanes: LongInt;
  Planes: cplane_s;

  NumLeafs: LongInt;
  Leafs: Pointer;

  NumLeafWaterData: LongInt;
  LeafWaterData: Pointer;

  NumVertexes: LongInt;
  Vertexes: Pointer;

  NumOccluders: LongInt;
  Occluders: Pointer;

  NumOccluderPolys: LongInt;
  OccluderPolys: Pointer;

  NumOccluderVertindices: LongInt;
  OccluderVertindices: PLongInt;

  NumVertnormalIndices: LongInt;
  VertnormalIndices: PWord;

  NumVertnormals: LongInt;
  Vertnormals: PVector;

  NumNodes: LongInt;
  FirstNode: LongInt;
  Nodes: mnode_s;
  m_LeafMinDistToWater: PWord;

  NumTexInfo: LongInt;
  TexInfo: Pointer;

  NumTexData: LongInt;
  TexData: Pointer;

  NumDispInfos: LongInt;
  DispInfos: Pointer; // HDISPINFOARRAY;

// Does it need?
//  NumOrigSurfaces: LongInt;
//  OrigSurfaces: Pointer;

  NumSurfaces: LongInt;
  Surfaces1: Pointer;
  Surfaces2: Pointer;
  SurfaceLighting: Pointer;

  NumVertindices: LongInt;
  Vertindices: PWord;

  NumMarkSurfaces: LongInt;
  MarkSurfaces: PLongInt;

  LightData: Pointer;

  NumWorldLights: LongInt;
  WorldLights: Pointer;

  NumPrimitives: LongInt;
  Primitives: Pointer;

  NumPrimVerts: LongInt;
  PrimVerts: Pointer;

  NumPrimIndices: LongInt;
  PrimIndices: PWord;

  m_nAreas: LongInt;
  m_pAreas: Pointer;

  m_nAreaPortals: LongInt;
  m_pAreaPortals: Pointer;

  m_nClipPortalVerts: LongInt;
  m_pClipPortalVerts: PVector;

  m_pCubemapSamples: Pointer;
  m_nCubemapSamples: LongInt;

 (* #if 0
 NumPortals: LongInt;
 Portals: Pointer;

 NumClisters: LongInt;
 Clusters: Pointer;

 NumPortalVerts: LongInt;
 PortalVerts: Pointer;

 NumClisterPortals: LongInt;
 ClisterPortals: Pointer;
 endif *)
 end;

type
 studiodata_s = ^studiodata_t;
 studiodata_t = record
{vcollide_t vcollisionData;
studiohwdata_t hardwareData;
bool studiomeshLoaded;
bool vcollisionLoaded; }
 end;

type
 spritedata_s = ^spritedata_t;
 spritedata_t = record
  NumFrames: LongInt;
  Sprite: ^CEngineSprite;
 end;

type
 model_s = ^model_t;
 model_t = record
  Name: array[0..MAX_QPATH - 1] of AnsiChar;

  NeedLoad: LongInt;

  ModelType: modtype_t;
  Flags: LongInt;

  Mins, Maxs: Vector;
  Rarius: Single;

  ExtraDataSize: LongInt;  
  Cache: cache_user_t;

  Brush: brushdata_t;
  Studio: studiodata_t;
  Sprite: spritedata_t;
 end;

// cmodel.h
const
 AREA_SOLID = 1;
 AREA_TRIGGERS = 2;

type
 PCPhysCollide = ^CPhysCollide;
 CPhysCollide = Pointer;

type
 vcollide_s = ^vcollide_t;
 vcollide_t = record
  SolidCount: LongInt;
  Solids: PCPhysCollide;
  KeyValues: PAnsiChar;
 end;

type
 cmodel_s = ^cmodel_t;
 cmodel_t = record
  Mins, Maxs: Vector;
  Origin: Vector;
  Headnode: LongInt;

  VCollisionData: vcollide_t;
 end;

type
 csurface_s = ^csurface_t;
 csurface_t = record
  Name: PAnsiChar;
  SurfaceProps: SmallInt;
  Flahs: Word;
 end;

type
 Ray_s = ^Ray_t;
 Ray_t = record
  m_Start: Vector;
  m_Delta: Vector;
  m_StartOffset: Vector;
  m_Extents: Vector;
  m_IsRay: Boolean;
  m_IsSwept: Boolean;
  Init1: procedure(VecStart, VecEnd: Vector);
  Init2: procedure(VecStart, VecEnd, VecMins, VecMaxs: Vector);
 end;

type
 PRay = ^TRay;
 TRay = record
  // ????????????????
 end;

// bsplib.h
type
 PISpatialQuery = ^ISpatialQuery;
 ISpatialQuery = record
  LeafCount: function: LongInt; cdecl;

  EnumerateLeavesAtPoint: function(pt: PVector; PEnum: PISpatialLeafEnumerator; Context: LongInt): Boolean; cdecl;
  EnumerateLeavesInBox: function(Mins, Max: PVector; PEnum: PISpatialLeafEnumerator; Context: LongInt): Boolean; cdecl;
  EnumerateLeavesInSphere: function(Center: PVector; Radius: Single; PEnum: PISpatialLeafEnumerator; Context: LongInt): Boolean; cdecl;
  EnumerateLeavesAlongRay: function(Ray:{FIXFIXFIX} Pointer; PEnum: ISpatialLeafEnumerator; Context: LongInt): Boolean; cdecl;
 end;

// edict.h

type
 MapLoadType_t = (MapLoad_NewGame = 0, MapLoad_LoadGame, MapLoad_Transition);

const
 MAX_ENT_CLUSTERS = 24;

type
 edict_s = ^edict_t;
 edict_t = record
  GetCollideable: function: Pointer; // PICollideable
  ClassName: LongInt; // string_t
  Free: Boolean;
  FreeTime: Single;
  SerialNumber: Byte;
  EntityCreated: LongInt;
  Partition: Word;
  ClusterCount: LongInt;
  Clusters: array[1..MAX_ENT_CLUSTERS] of LongInt;
  Headnode: LongInt;
  Arenum: LongInt;
  Arenum2: LongInt;
 end;

// client_command.h
type
 cmd_s = ^cmd_t;
 cmd_t = record
  SentTime: Single;
  ReceivedTime: Single;
  FrameLerp: Single;
  ProcessedFuncs: Boolean;
  HeldBack: Boolean;
  SendSize: LongInt;
 end;

// con_nprint.h
type
 con_nprint_s = ^con_nprint_t;
 con_nprint_t = record
  Index: LongInt;
  TimeToLive: Single;
  Color: array[1..3] of Single;
  FixedWidthFont: Boolean;
 end;

// terrainmod.h
type
 TerrainFlags = (TMOD_SUCKTONORMAL = 1, TMOD_STAYABOVEORIGINAL);

type
 TerrainModType = (TMod_Sphere = 0, TMod_Suck, TMod_AABB);

type
 CTerrainModParams = record
  Flags: TerrainFlags;
  CTerrainModParams: procedure; cdecl;
  m_vCenter: Vector;
  m_vNormal: Vector;
  m_Flags: LongInt;
  m_flRadius: Single;
  m_vecMin: Vector;
  m_vecMax: Vector;
  m_flStrength: Single;
  m_flMorphTime: Single;
 end;


// client_textmessage.h
type
 client_textmessage_s = ^client_textmessage_t;
 client_textmessage_t = record
  Effect: LongInt;
  R1, G1, B1, A1: Byte;
  R2, G2, B2, A2: Byte;
  X, Y: Single;
  FadeIn, FadeOut: Single;
  HoldTime: Single;
  FxTime: Single;
  VGuiSchemeFontName: PAnsiChar;
  Name: PAnsiChar;
  Msg: PAnsiChar;
  RoundedRectBackdropBox: Boolean;
  BoxSize: Single;
  BoxColor: array[1..4] of Byte;
  ClearMessage: PAnsiChar;
 end;

// ButtonCode.h
type
 ButtonCode_s = ^ButtonCode_t;
 ButtonCode_t = (
  BUTTON_CODE_INVALID = -1,
  BUTTON_CODE_NONE = 0,

  KEY_FIRST = 0,

  KEY_NONE = KEY_FIRST,
  KEY_0,
  KEY_1,
  KEY_2,
  KEY_3,
  KEY_4,
  KEY_5,
  KEY_6,
  KEY_7,
  KEY_8,
  KEY_9,
  KEY_A,
  KEY_B,
  KEY_C,
  KEY_D,
  KEY_E,
  KEY_F,
  KEY_G,
  KEY_H,
  KEY_I,
  KEY_J,
  KEY_K,
  KEY_L,
  KEY_M,
  KEY_N,
  KEY_O,
  KEY_P,
  KEY_Q,
  KEY_R,
  KEY_S,
  KEY_T,
  KEY_U,
  KEY_V,
  KEY_W,
  KEY_X,
  KEY_Y,
  KEY_Z,
  KEY_PAD_0,
  KEY_PAD_1,
  KEY_PAD_2,
  KEY_PAD_3,
  KEY_PAD_4,
  KEY_PAD_5,
  KEY_PAD_6,
  KEY_PAD_7,
  KEY_PAD_8,
  KEY_PAD_9,
  KEY_PAD_DIVIDE,
  KEY_PAD_MULTIPLY,
  KEY_PAD_MINUS,
  KEY_PAD_PLUS,
  KEY_PAD_ENTER,
  KEY_PAD_DECIMAL,
  KEY_LBRACKET,
  KEY_RBRACKET,
  KEY_SEMICOLON,
  KEY_APOSTROPHE,
  KEY_BACKQUOTE,
  KEY_COMMA,
  KEY_PERIOD,
  KEY_SLASH,
  KEY_BACKSLASH,
  KEY_MINUS,
  KEY_EQUAL,
  KEY_ENTER,
  KEY_SPACE,
  KEY_BACKSPACE,
  KEY_TAB,
  KEY_CAPSLOCK,
  KEY_NUMLOCK,
  KEY_ESCAPE,
  KEY_SCROLLLOCK,
  KEY_INSERT,
  KEY_DELETE,
  KEY_HOME,
  KEY_END,
  KEY_PAGEUP,
  KEY_PAGEDOWN,
  KEY_BREAK,
  KEY_LSHIFT,
  KEY_RSHIFT,
  KEY_LALT,
  KEY_RALT,
  KEY_LCONTROL,
  KEY_RCONTROL,
  KEY_LWIN,
  KEY_RWIN,
  KEY_APP,
  KEY_UP,
  KEY_LEFT,
  KEY_DOWN,
  KEY_RIGHT,
  KEY_F1,
  KEY_F2,
  KEY_F3,
  KEY_F4,
  KEY_F5,
  KEY_F6,
  KEY_F7,
  KEY_F8,
  KEY_F9,
  KEY_F10,
  KEY_F11,
  KEY_F12,
  KEY_CAPSLOCKTOGGLE,
  KEY_NUMLOCKTOGGLE,
  KEY_SCROLLLOCKTOGGLE,
  
  KEY_LAST = KEY_SCROLLLOCKTOGGLE,
  KEY_COUNT = KEY_LAST - KEY_FIRST + 1,
  
  // Mouse
  MOUSE_FIRST = KEY_LAST + 1,
  
  MOUSE_LEFT = MOUSE_FIRST,
  MOUSE_RIGHT,
  MOUSE_MIDDLE,
  MOUSE_4,
  MOUSE_5,
  MOUSE_WHEEL_UP,
  MOUSE_WHEEL_DOWN,
  
  MOUSE_LAST = MOUSE_WHEEL_DOWN,
  MOUSE_COUNT = MOUSE_LAST - MOUSE_FIRST + 1,
  
  JOYSTICK_FIRST = MOUSE_LAST + 1,
  
  JOYSTICK_FIRST_BUTTON = JOYSTICK_FIRST,   // Too lazy for fix
  JOYSTICK_LAST_BUTTON = 0, // JOYSTICK_BUTTON_INTERNAL( MAX_JOYSTICKS-1, JOYSTICK_MAX_BUTTON_COUNT-1 ),
  JOYSTICK_FIRST_POV_BUTTON,
  JOYSTICK_LAST_POV_BUTTON = 0, // JOYSTICK_POV_BUTTON_INTERNAL( MAX_JOYSTICKS-1, JOYSTICK_POV_BUTTON_COUNT-1 ),
  JOYSTICK_FIRST_AXIS_BUTTON,
  JOYSTICK_LAST_AXIS_BUTTON = 0, //JOYSTICK_AXIS_BUTTON_INTERNAL( MAX_JOYSTICKS-1, JOYSTICK_AXIS_BUTTON_COUNT-1 ),
  
  JOYSTICK_LAST = JOYSTICK_LAST_AXIS_BUTTON,
  
  BUTTON_CODE_LAST,
  BUTTON_CODE_COUNT = BUTTON_CODE_LAST - KEY_FIRST + 1,
  
  KEY_XBUTTON_UP = JOYSTICK_FIRST_POV_BUTTON,
  KEY_XBUTTON_RIGHT,
  KEY_XBUTTON_DOWN,
  KEY_XBUTTON_LEFT,
  
  KEY_XBUTTON_A = JOYSTICK_FIRST_BUTTON,
  KEY_XBUTTON_B,
  KEY_XBUTTON_X,
  KEY_XBUTTON_Y,
  KEY_XBUTTON_LEFT_SHOULDER,
  KEY_XBUTTON_RIGHT_SHOULDER,
  KEY_XBUTTON_BACK,
  KEY_XBUTTON_START,
  KEY_XBUTTON_STICK1,
  KEY_XBUTTON_STICK2,
  
  KEY_XSTICK1_RIGHT = JOYSTICK_FIRST_AXIS_BUTTON,
  KEY_XSTICK1_LEFT,
  KEY_XSTICK1_DOWN,
  KEY_XSTICK1_UP,
  KEY_XBUTTON_LTRIGGER,
  KEY_XBUTTON_RTRIGGER,
  KEY_XSTICK2_RIGHT,
  KEY_XSTICK2_LEFT,
  KEY_XSTICK2_DOWN,
  KEY_XSTICK2_UP);

// ivdebugoverlay.h
type
 PIVDebugOverlay = ^IVDebugOverlay;
 IVDebugOverlay = record
  AddEntityTextOverlay: procedure(EntIndex, LineOffset: LongInt; Duration: Single; R, G, B, A: LongInt; const Msg: PAnsiChar); cdecl varargs;
// QAngle
  AddBoxOverlay: procedure(const Origin, Mins, Maxs: Vector; Orientation: Pointer; R, G, B, A: LongInt; Duration: Single); cdecl;
  AddTriangleOverlay: procedure(const P1, P2, P3: PVector; R, G, B, A: LongInt; DepthTest: Boolean; Duration: Single); cdecl;
  AddLineOverlay: procedure(const Origin, Dest: PVector; R, G, B: LongInt; DepthTest: Boolean; Duration: Single);
  AddTextOverlay: procedure(); cdecl varargs;
  AddTextOverlay2: procedure(); cdecl varargs;
  AddScreenTextOverlay: procedure(); cdecl;
  AddSweptBoxOverlay: procedure(); cdecl;
  AddGridOverlay: procedure(); cdecl;
  ScreenPosition: function(): LongInt; cdecl;
  ScreenPosition2: function(): LongInt; cdecl;
  GetFirst: function: Pointer; cdecl;
  GetNext: function(): Pointer; cdecl;
  ClearDeadOverlays: procedure; cdecl;
  ClearAllOverlays: procedure; cdecl;
  AddTextOverlayRGB: procedure(); cdecl varargs;
  AddTextOverlayRGB2: procedure(); cdecl varargs;
  AddLineOverlayAlpha: procedure(); cdecl;
  AddBoxOverlay2: procedure(); cdecl;
 end;

// bitbuf.h
type
 PBF_Write = ^BF_Write;
 BF_Write = record
  BF_Write1: procedure; stdcall;

  BF_Write2: procedure(Data: Pointer; Bytes: LongInt; MaxBits: LongInt = -1); stdcall;
  BF_Write3: procedure(DebugName: PAnsiChar; Data: Pointer; Bytes: LongInt; MaxBits: LongInt = -1); stdcall;

  StartWriting: procedure(Data: Pointer; Bytes: LongInt; StartBit: LongInt = 0; MaxBits: LongInt = -1); stdcall;

  Reset: procedure; stdcall;

  GetBasePointer: PAnsiChar;

  SetAssertOnOverflow: procedure(Assert: Boolean); stdcall;

  GetDebugName: function: PAnsiChar; stdcall;
  SetDebugName: procedure(DebugName: PAnsiChar); stdcall;

  SeekToBit: procedure(BitPos: LongInt); stdcall;

  WriteOneBit: procedure(Value: LongInt); stdcall;
  WriteOneBitNoCheck: procedure(Value: LongInt); stdcall;
  WriteOneBitAt: procedure(Bit: LongInt; Value: LongInt); stdcall;

  WriteUBitLong: procedure(Data: LongWord; NumBits: LongInt; CheckRange: Boolean = True); stdcall;
  WriteSBitLong: procedure(Data: LongInt; NumBits: LongInt); stdcall;

  WriteBitLong: procedure(Data: LongWord; NumBits: LongInt; Signer: Boolean); stdcall;

  WriteBits: function(const PIn: Pointer; Bits: LongInt): Boolean; stdcall;
  WriteUBitVar: procedure(Data: LongWord); stdcall;

  WriteVarInt32: procedure(Data: LongWord); stdcall;
  WriteVarInt64: procedure(Data: UInt64); stdcall;
  WriteSignedVarInt32: procedure(Data: LongInt); stdcall;
  WriteSignedVarInt64: procedure(Data: Int64); stdcall;
  ByteSizeVarInt32: function(Data: LongWord): LongInt; stdcall;
  ByteSizeVarInt64: function(Data: UInt64): LongInt; stdcall;
  ByteSizeSignedVarInt32: function(Data: LongInt): LongInt; stdcall;
  ByteSizeSignedVarInt64: function(Data: Int64): LongInt; stdcall;

  // bf_read
  WriteBitsFromBuffer: function(PIn: Pointer; Bits: LongInt): Boolean; stdcall;

  WriteBitAngle: procedure(Angle: Single; NumBits: LongInt); stdcall;
  WriteBitCoord: procedure(const F: Single); stdcall;
  WriteBitCoordMP: procedure(F: Single; Internal: Boolean; LowPrecision: Boolean); stdcall;
  WriteBitFloat: procedure(Val: Single); stdcall;
  WriteBitVec3Coord: procedure(FA: PVector); stdcall;
  WriteBitNormal: procedure(F: Single); stdcall;
  WriteBitVec3Normal: procedure(FA: PVector); stdcall;
  // QAngle
  WriteBitAngles: procedure(FA: Pointer); stdcall;

  WriteChar: procedure(Val: LongInt); stdcall;
  WriteByte: procedure(Val: LongInt); stdcall;
  WriteShort: procedure(Val: LongInt); stdcall;
  WriteWord: procedure(Val: LongInt); stdcall;
  WriteLong: procedure(Val: LongWord); stdcall;
  WriteLongLong: procedure(Val: Int64); stdcall;
  WriteFloat: procedure(Val: Single); stdcall;
  WriteBytes: procedure(Buf: Pointer; Bytes: LongInt); stdcall;

  WriteString: function(Str: PAnsiChar): Boolean; stdcall;

  GetNumBytesWritten: function: LongInt; stdcall;
  GetNumBitsWritten: function: LongInt; stdcall;
  GetMaxNumBits: function: LongInt; stdcall;
  GetNumBitsLeft: function: LongInt; stdcall;
  GetNumBytesLeft: function: LongInt; stdcall;
  GetData1: function: PAnsiChar; stdcall;
  GetData2: function: PAnsiChar; stdcall;

  CheckForOverflow: function(Bits: LongInt): Boolean; stdcall;
  IsOverflowed: function: Boolean; stdcall;
         
  SetOverflowFlag: procedure; stdcall;

  m_pData: PLongWord;
  m_nDataBytes: LongInt;
  m_nDataBits: LongInt;

  m_iCurBit: LongInt;
 end;

type
 BF_Read = record

 end;

// inetmessage.h
type
 PProcessFunc = ^TProcessFunc;
 TProcessFunc = function: Boolean; stdcall;

 PINetMessage = ^INetMessage;
 INetMessage = record
  Destroy: procedure(B: Boolean); stdcall;

  SetNetChannel: procedure(Netchan: Pointer); stdcall;
  SetReliable: procedure(State: Boolean); stdcall;

  Process: TProcessFunc;

  ReadFromBuffer: function(Buffer: Pointer): Boolean; stdcall;
  WriteToBuffer: function(Buffer: Pointer): Boolean; stdcall;

  IsReliable: function: Boolean; stdcall;

  GetType: function: LongInt; stdcall;
  GetGroup: function: LongInt; stdcall;
  GetName: function: PAnsiChar; stdcall;
  GetNetChannel: function: Pointer; stdcall;
  ToString: function: PAnsiChar; stdcall;
 end;

// inetmsghandler.h
type
 PINetChannelHandler = ^INetChannelHandler;
 INetChannelHandler = record
  Destroy: procedure; stdcall;

  ConnectionStart: procedure(Channel: Pointer); stdcall;
  ConnectionClosing: procedure(const Reason: PAnsiChar); stdcall;
  ConnectionCrashed: procedure(const Reason: PAnsiChar); stdcall;
  PacketStart: procedure(IncomingSeq: LongInt; OutgoingAck: LongInt); stdcall;
  PacketEnd: procedure; stdcall;
  FileRequested: procedure(const FileName: PAnsiChar; TransferID: LongWord); stdcall;
  FileReceived: procedure(const FileName: PAnsiChar; TransferID: LongWord); stdcall;
  FileDenied: procedure(const FileName: PAnsiChar; TransferID: LongWord); stdcall;
  FileSent: procedure(const FileName: PAnsiChar; TransferID: LongWord); stdcall;
 end;

// netard.h
type
 netadrtype_t =
 (NA_UNUSED,
  NA_LOOPBACK,
  NA_BROADCAST,
  NA_IP,
  NA_IPX,
  NA_BROADCAST_IPX);

type
  netadr_s = ^netadr_t;
  netadr_t = record
    AddrType: netadrtype_t;
    IP: array[0..3] of Byte;
    Port: Word;
  end;

// inetchannel.h
type
 netpacket_s = ^netpacket_t;
 netpacket_t = record
  From: netadr_t;
  Source: LongInt;
  Received: Double;
  Data: PAnsiChar;
  Message: BF_Read;
  Size: LongInt;
  WireSize: LongInt;
  Stream: Boolean;
  Next: netpacket_s;
 end;

type
 PINetChannel = ^INetChannel;
 INetChannel = record
  Destroy: procedure; stdcall;

  SetDataRate: procedure(Rate: Single); stdcall;
  RegisterMessage: function(Msg: PINetMessage): Boolean; stdcall;
  StartStreaming: function(ChallengeNr: LongWord): Boolean; stdcall;
  ResetStreaming: procedure; stdcall;
  SetTimeout: procedure(Seconds: Single); stdcall;
  SetDemoRecorder: procedure(Recorder: Pointer); stdcall;
  SetChallengeNr: procedure(Chnr: LongWord); stdcall;

  Reset: procedure; stdcall;
  Clear: procedure; stdcall;
  Shutdown: procedure(Reason: PAnsiChar); stdcall;

  ProcessPlayback: procedure; stdcall;
  ProcessStream: function: Boolean; stdcall;
  ProcessPacket: procedure(Packet: Pointer; HasHeader: Boolean);

  // <! userpurge !>
  {SendNetMsg<al>(int a1<ecx>, int a2<esi>, int a3, char a4, char a5)}
  SendNetMsg: function(Msg: PINetMessage; ForceReliable: Boolean = False; Voice: Boolean = False): Boolean; stdcall;

  SendData: function(const Msg: PINetMessage; ForceReliable: Boolean = False; Voice: Boolean = False): Boolean; stdcall;
  SendFile: function(FileName: PAnsiChar; TransferID: LongInt): Boolean; stdcall;
  DenyFile: procedure(FileName: PAnsiChar; TransferID: LongInt); stdcall;
  RequestFile_OLD: procedure(FileName: PAnsiChar; TransferID: LongInt); stdcall;
  SetChoked: procedure; stdcall;
  // <! userpurge !>
  {SendDatagram<eax>(int a1<ebx>, int a2<esi>, int ecx0<ecx>, int a3)}
  SendDatagram: function(Data: PBF_Write): LongInt; stdcall;
  Transmit: function(OnlyReliable: Boolean = False): Boolean; stdcall;

  GetRemoteAddress: function: netadr_s; stdcall;
  GetMsgHandler: function: PINetChannelHandler; stdcall;
  GetDropNumber: function: LongInt; stdcall;
  GetSocket: function: LongInt; stdcall;
  GetChallengeNr: function: LongWord; stdcall;
  GetSequenceData: procedure(OutSequenceNr, InSequenceNr, OutSequenceNrAck: PLongInt); stdcall;
  SetSequenceData: procedure(OutSequenceNr, InSequenceNr, OutSequenceNrAck: LongInt); stdcall;

  UpdateMessageStats: procedure(MsgGroup: LongInt; Bits: LongInt); stdcall;
  CanPacket: function: Boolean; stdcall;
  IsOverflowed: function: Boolean; stdcall;
  IsTimedOut: function: Boolean; stdcall;
  HasPendingReliableData: function: Boolean; stdcall;

  SetFileTransmissionMode: procedure(BackgroundMode: Boolean); stdcall;
  SetCompressionMode: procedure(UseCompression: Boolean); stdcall;
  RequestFile: function(const FileName: PAnsiChar): LongWord; stdcall;
  GetTimeSinceLastReceived: function: Single; stdcall;

  SetMaxBufferSize: procedure(Reliable: Boolean; Bytes: LongInt; Voice: Boolean = False); stdcall;

  IsNull: function: Boolean; stdcall;
  GetNumBitsWritten: function(Reliable: Boolean): LongInt; stdcall;
  SetInterpolationAmount: procedure(Amount: Single); stdcall;
  SetRemoteFramerate: procedure(FrameTime: Single; FrameTimeStdDeviation: Single); stdcall;

  SetMaxRoutablePayloadSize: procedure(SplitSize: LongInt); stdcall;
  GetMaxRoutablePayloadSize: function: LongInt; stdcall;

//  GetProtocolVersion: function: LongInt; stdcall;
 end;

// inetchannelinfo.h
const
 FLOW_OUTGOING = 0;
 FLOW_INCOMING = 1;
 MAX_FLOWS = 2;

type
 PINetChannelInfo = ^INetChannelInfo;
 INetChannelInfo = record
  GetName: function: PAnsiChar; stdcall; // +0
  GetAddress: function: PAnsiChar; stdcall; // +4
  GetTime: function: Single; stdcall; // +8
  GetTimeConnected: function: Single; stdcall; // +12
  GetBufferSize: function: LongInt; stdcall; // +16
  GetDataRate: function: LongInt; stdcall; // +20

  IsLoopback: function: Boolean; stdcall; // +24
  IsTimingOut: function: Boolean; stdcall; // +28
  IsPlayback: function: Boolean; stdcall; // +32

  GetLatency: function(Flow: LongInt): Single; stdcall; // +36
  GetAvgLatency: function(Flow: LongInt): Single; stdcall; // +40
  GetAvgLoss: function(Flow: LongInt): Single; stdcall; // +44
  GetAvgChoke: function(Flow: LongInt): Single; stdcall; // +48
  GetAvgData: function(Flow: LongInt): Single; stdcall; // +52
  GetAvgPackets: function(Flow: LongInt): Single; stdcall; // +56
  GetTotalData: function(Flow: LongInt): LongInt; stdcall; // +60
  GetSequenceNr: function(Flow: LongInt): LongInt; stdcall; // +64
  IsValidPacket: function(Flow: LongInt; FrameNumber: LongInt): Boolean; stdcall; // +68
  GetPacketTime: function(Flow: LongInt; FrameNumber: LongInt): Single; stdcall; // +72
  GetPacketBytes: function(Flow: LongInt; FrameNumber: LongInt; Group: LongInt): LongInt; stdcall; // +76
  GetStreamProgress: function(Flow: LongInt; Received: PLongInt; Total: PLongInt): Boolean; stdcall; // +80
  GetTimeSinceLastReceived: function: Single; stdcall; // +84
  GetCommandInterpolationAmount: function(Flow: LongInt; FrameNumber: LongInt): Single; stdcall; // +88
  GetPacketResponseLatency: procedure(Flow: LongInt; FrameNumber: LongInt; LatencyMsecs, Choke: PLongInt); stdcall; // +92
  GetRemoteFramerate: procedure(FrameTime: Single; FrameTimeStdDeviation: Single); stdcall; // +96

  GetTimeoutSeconds: function: Single; stdcall; // +100

  Channel: INetChannel; // +104
 end;

// cdll_int.h
type
 ClientFrameStage_t = (FRAME_UNDEFINED = 1,
                       FRAME_START,
                       FRAME_NET_UPDATE_START,
                       FRAME_NET_UPDATE_POSTDATAUPDATE_START,
                       FRAME_NET_UPDATE_POSTDATAUPDATE_END,
                       FRAME_NET_UPDATE_END,
                       FRAME_RENDER_START,
                       FRAME_RENDER_END);

 RenderViewInfo_t = (RENDERVIEW_UNSPECIFIED = 0,
                     RENDERVIEW_DRAWVIEWMODEL = 1 shl 0,
                     RENDERVIEW_DRAWHUD = 1 shl 1,
                     RENDERVIEW_SUPPRESSMONITORRENDERING = 1 shl 2);
 AudioState_t = record
   m_Origin: Vector;
   Angles: Pointer; // todo: QAngle
   m_bIsUnderwater: Boolean;
 end;

const
 VENGINE_CLIENT_RANDOM_INTERFACE_VERSION001: PAnsiChar = 'VEngineRandom001'; // engine.dll

type
 TSkyboxVisibility = (SKYBOX_NOT_VISIBLE = 0, SKYBOX_3DSKYBOX_VISIBLE, SKYBOX_2DSKYBOX_VISIBLE);

type
 hud_player_info_s = ^hud_player_info_t;
 hud_player_info_t = record
  ThisPlayer: Boolean;
  Name: PAnsiChar;
  Model: PAnsiChar;
  Logo: LongInt;
 end;

type
 POcclusionParams = ^TOcclusionParams;
 TOcclusionParams = record
  m_flMaxOccludeeArea: Single;
  m_flMinOccluderArea: Single;
 end;

type
 TUPlayerID = array[1..16] of AnsiChar;
 
(*type
 PIVEngineClient = ^IVEngineClient;
 IVEngineClient = record                                                                // Pointer = SurfInfo
  GetIntersectingSurfaces: function(const Model: model_s; const Center: Vector; const Radius: Single; OnlyVisibleSurfaces: Boolean; Infos: Pointer; const MaxInfos: LongInt): LongInt; stdcall;
  GetLightForPoint: function(const Pos: Vector): Vector; stdcall;
// IMaterial
  TraceLineMaterialAndLighting: function(const VecStart, VecEnd, DiffuseLightColor, BaseColor: Vector): Pointer; stdcall;
  COM_ParseFile: function(Data: PAnsiChar; Token: PAnsiChar; MaxLen: LongInt): PAnsiChar; stdcall;
  COM_CopyLocalFile: function(const Source, Dectination: PAnsiChar): Boolean; stdcall;
  GetScreenSize: procedure(Widht: PLongInt; Height: PLongInt); stdcall;
  ServerCmd: function(const CmdString: PAnsiChar; Reliable: Boolean = True): LongInt; stdcall;
  ClientCmd: function(const CmdString: PAnsiChar): LongInt; stdcall;
  GetPlayerInfo: procedure(EntNum: LongInt; Info: hud_player_info_s); stdcall;
  GetPlayerUniqueID: function(Player: LongInt; PlayerID: TUPlayerID): Boolean; stdcall;
  TextMessageGet: function(Name: PAnsiChar): client_textmessage_s; stdcall;
  Con_IsVisible: function: Boolean; stdcall;
  GetLocalPlayer: function: LongInt; cdecl;
  LoadModel: function(const Name: PAnsiChar; IsProp: Boolean = False): model_s; cdecl;
  Time: function: Single; cdecl;
  GetLastTimeStamp: function: Double; stdcall;
// CSentence, CAudioSource
  GetSentence: function(AudioSource: Pointer): Pointer; stdcall;
// CAudioSource
  GetSentenceLength: function(AudioSource: Pointer): Single; cdecl;
// CAudioSource
  IsStreaming: function(AudioSource: Pointer): Boolean; stdcall;
// QAngle
  GetViewAngles: procedure(VA: Pointer); stdcall;
// QAngle  
  SetViewAngles: procedure(VA: Pointer); stdcall;
  GetMaxClients: function: LongInt; cdecl;
  Key_LookupBinding: function(const Binding: PAnsiChar): PAnsiChar; stdcall;
  Key_BindingForKey: function(Code: ButtonCode_s): PAnsiChar; cdecl;
  StartKeyTrapMode: procedure; cdecl;
  CheckDoneKeyTrapping: function(Code: ButtonCode_s): Boolean; cdecl;
  IsInGame: function: LongInt; cdecl;
  IsConnected: function: Boolean; cdecl;
  IsDrawingLoadingImage: function: Boolean; cdecl;
  Con_NPrintf: procedure(Position: LongInt; Msg: PAnsiChar) cdecl varargs;
  Con_NXPrintf: procedure(Info: con_nprint_s; Msg: PAnsiChar) cdecl varargs;
  IsBoxVisible: function(const Mins, Maxs: Vector): LongInt; stdcall;
  IsBoxInViewCluster: function(const Mins, Maxs: Vector): LongInt; stdcall;
  CullBox: function(const Mins, Maxs: Vector): Boolean; stdcall;
  Sound_ExtraUpdate: procedure; cdecl;
  GetGameDirectory: function: PAnsiChar; cdecl;
// VMatrix
  WorldToScreenMatrix: function: Pointer; cdecl;
// VMatrix
  WorldToViewMatrix: function: Pointer; cdecl;
  GameLumpVersion: function(LumpID: LongInt): LongInt; stdcall;
  GameLumpSize: function(LumpID: LongInt): LongInt; stdcall;
  LoadGameLump: function(LumpID: LongInt; Buffer: Pointer; Size: LongInt): Boolean; stdcall;
  LevelLeafCount: function: LongInt; cdecl;
  GetBSPTreeQuery: function: PISpatialQuery; cdecl;
  LinearToGamma: procedure(Linear: PSingle; Gamma: PSingle); stdcall;
  LightStyleValue: function(Style: LongInt): Single; stdcall;
  ComputeDynamicLighting: procedure(PT: PVector; Normal: PVector; Color: PVector); stdcall;
  GetAmbientLightColor: procedure(Color: PVector); stdcall;
  GetDXSupportLevel: function: LongInt; cdecl;
  SupportsHDR: function: Boolean; cdecl; // always = False
// IMaterialSystem
  Mat_Stub: procedure(MatSys: Pointer); stdcall;
  GetChapterName: procedure(Buff: PAnsiChar; MaxLength: LongInt); stdcall;
  GetLevelName: function: PAnsiChar; cdecl;
  GetLevelVersion: function: LongInt; cdecl;
  GetVoiceTweakAPI: function: Pointer; cdecl;
  EngineStats_BeginFrame: procedure; cdecl;
  EngineStats_EndFrame: procedure; cdecl; // doesn't do anything
  FireEvents: procedure; cdecl;
  GetLeavesArea: function(Leaves: PLongInt; NumLeaves: LongInt): LongInt; stdcall;
  DoesBoxTouchAreaFrustum: function(Mins, Maxs: PVector; Area: LongInt): Boolean; stdcall;
// AudioState_s
  SetAudioState: procedure(const State: Pointer); stdcall;
// QAngle
  SentenceGroupPick: function(GroupIndex: LongInt; Name: PAnsiChar; NameLen: LongInt): LongInt; stdcall;
  SentenceGroupPickSequential: function(roupIndex: LongInt; Name: PAnsiChar; NameLen: LongInt; SentenceIndex: LongInt; Reset: LongInt): LongInt; stdcall;
  SentenceIndexFromName: function(const SentenceName: PAnsiChar): LongInt; stdcall;
  SentenceNameFromIndex: function(SentenceIndex: LongInt): PAnsiChar; stdcall;
  SentenceGroupIndexFromName: function(const GroupName: PAnsiChar): LongInt; stdcall;
  SentenceGroupNameFromIndex: function(GroupIndex: LongInt): PAnsiChar; stdcall;
  SentenceLength: function(SentenceIndex: LongInt): Single; stdcall;
  ComputeLighting: procedure(PT, Normal: PVector; Clamp: Boolean; Color: PVector; BoxColors: PVector = nil); stdcall;
  ActivateOccluder: procedure(OccluderIndex: LongInt; Active: Boolean); cdecl;
  IsOccluded: function(const VecAbsMin, VecAbsMax: PVector): Boolean; cdecl;
  SaveAllocMemory: function(Num, Size: size_t; Clear: Boolean = False): Pointer; stdcall;
  SaveFreeMemory: procedure(SaveMem: Pointer); stdcall;
  GetNetChannelInfo: function: PINetChannelInfo; cdecl;
// IMaterial, matrix3x4_t, color32
  DebugDrawPhysCollide: procedure(const Collide: PCPhysCollide; Material: Pointer; Transform: Pointer; Color: Pointer); stdcall;
  CheckPoint: procedure(Name: PAnsiChar); stdcall;
  DrawPortals: procedure; cdecl;
  IsPlayingDemo: function: Boolean; cdecl;
  IsRecordingDemo: function: Boolean; cdecl;
  IsPlayingTimeDemo: function: Boolean; cdecl;
  GetDemoRecordingTick: function: LongInt; cdecl;
  GetDemoPlaybackTick: function: LongInt; cdecl;
  GetDemoPlaybackStartTick: function: LongInt; cdecl;
  GetDemoPlaybackTimeScale: function: Single; cdecl;
  GetDemoPlaybackTotalTicks: function: LongInt; cdecl;
  IsPaused: function: Boolean; cdecl;
  IsTakingScreenshot: function: Boolean; cdecl;
  IsHLTV: function: Boolean; cdecl;
  IsLevelMainMenuBackground: function: Boolean; cdecl;
  GetMainMenuBackgroundName: procedure(Dest: PAnsiChar; DestLen: LongInt); stdcall;
// vmode_s
  GetVideoModes: procedure(Count: LongInt; Modes: Pointer); stdcall;
  SetOcclusionParameters: procedure(Params: POcclusionParams); stdcall;
  GetUILanguage: procedure(Dest: PAnsiChar; DestLen: LongInt); stdcall;
  IsSkyboxVisibleFromPoint: function(const VecPoint: PVector): TSkyboxVisibility; stdcall;
  GetMapEntitiesString: function: PAnsiChar; cdecl;
  IsInEditMode: function: Boolean; cdecl;
  GetScreenAspectRatio: function: Single;
  REMOVED_SteamRefreshLogin: function(const Password: PAnsiChar; IsSecure: Boolean): Boolean; cdecl; // always = False
  REMOVED_SteamProcessCall: function(Finished: PBoolean): Boolean; cdecl; // always = False
  GetEngineBuildNumber: function: LongInt; cdecl; // does not make any mathematical operations, just returns current build number
  GetProductVersionString: function: PAnsiChar; cdecl;
  GrabPreColorCorrectedFrame: procedure(X, Y, Widht, Height: LongInt); cdecl;
  IsHammerRunning: function: Boolean; cdecl;
  ExecuteClientCmd: procedure(const CmdString: PAnsiChar); stdcall;
  MapHasHDRLighting: function: Boolean; cdecl;
  GetAppID: function: LongInt; cdecl;
  GetLightForPointFast: function(const Pos: PVector; Clamp: Boolean): Vector; stdcall;
  ClientCmd_Unrestricted: procedure(const CmdString: PAnsiChar); stdcall;
  SetRestrictServerCommands: procedure(Restrict: Boolean); stdcall;
  SetRestrictClientCommands: procedure(Restrict: Boolean); stdcall;
  SetOverlayBindProxy: procedure(OverlayID: LongInt; BindProxy: Pointer); cdecl;
  CopyFrameBufferToMaterial: function(MaterialName: PAnsiChar): Boolean; stdcall; // I think this does not works
  ChangeTeam: procedure(const TeamName: PAnsiChar); cdecl;
  ReadConfiguration: procedure(const ReadDefault: Boolean = False); stdcall;
// IAchievementMgr
  SetAchievementMgr: procedure(AchievementMgr: Pointer); stdcall;
// IAchievementMgr
  GetAchievementMgr: function: Pointer; cdecl;
  MapLoadFailed: function: Boolean; cdecl;
  SetMapLoadFailed: procedure; cdecl;
  IsLowViolence: function: Boolean; cdecl;
  GetMostRecentSaveGame: function: PAnsiChar; cdecl;
  SetMostRecentSaveGame: procedure(const FileName: PAnsiChar); cdecl;
  StartXboxExitingProcess: procedure; cdecl; // does not do anything
  IsSaveInProgress: function: Boolean; cdecl;
  OnStorageDeviceAttached: function: LongWord; cdecl;
  OnStorageDeviceDetached: procedure; cdecl;
  ResetDemoInterpolation: procedure; cdecl;
// CGamestatsData
  SetGamestatsData: procedure(GamestatsData: Pointer); cdecl;
// CGamestatsData
  GetGamestatsData: function: Pointer; cdecl;
{#if defined( USE_SDL )
  GetMouseDelta: procedure(X, Y: PLongInt; IgnoreNextMouseDelta: Boolean = False); stdcall;
{#endif}
// KeyValues
  ServerCmdKeyValues: procedure(KeyValues: Pointer); cdecl;
  IsSkippingPlayback: function: Boolean; cdecl;
  IsLoadingDemo: function: Boolean; cdecl;
  IsPlayingDemoALocallyRecordedDemo: function: Boolean; cdecl;
  Key_LookupBindingExact: function(Binding: PAnsiChar): PAnsiChar; cdecl;
 end;*)

// random.h
type
 PIUniformRandomStream = ^IUniformRandomStream;
 IUniformRandomStream = record
  SetSeed: procedure(const Seed: LongInt); stdcall; // not works (empty function)
  RandomFloat: function(MinValue: Single = 0.0; MaxValue: Single = 1.0): Single; stdcall;
  RandomInt: function(MilValue, MaxValue: Integer): Integer; stdcall;
 end;

// crc.h
type
 MD5Context_s = ^MD5Context_t;
 MD5Context_t = record
  Buf: array[1..4] of LongWord;
  Bits: array[1..2] of LongWord;
  InBuf: array[1..64] of Byte;
 end;

type
 CRC32_t = LongWord;

// info.h
const
 MAX_INFO_STRING = 256;

// net.h (netchan)
const
 MAX_STREAMS = 2;

 MAX_RATE = 20000;
 MIN_RATE = 1000;

 DEFAULT_RATE = 9999.0;

 NET_MAX_PAYLOAD = 80000;

 HEADER_BYTES = 8 + MAX_STREAMS * 9;

 NET_MAX_MESSAGE = 80032; // PAD_NUMBER result

type
 NetSrc_t = (NS_CLIENT, NS_SERVER);

var
 net_local_adr: netadr_s;
 net_from: netadr_s;
// net_message: sizebuf_t;

// client.h
const
 MAX_SCOREBOARDNAME = 32;
 MAX_STYLESTRING = 64;

type
 lightstyle_s = ^lightstyle_t;
 lightstyle_t = record
  Length: LongInt;
  Map: array[1..MAX_STYLESTRING] of AnsiChar;
 end;

type
 player_info_s = ^player_info_t;
 player_info_t = record
  Name: array[1..MAX_PLAYER_NAME_LENGTH] of AnsiChar;
  UserID: LongInt;
  GUID: array[1..SIGNED_GUID_LEN + 1] of AnsiChar;
  FriendsID: LongWord;
  FriendsName: array[1..MAX_PLAYER_NAME_LENGTH] of AnsiChar;
  FakePlayer: Boolean;
  IsHLTV: Boolean;
  CustomFiles: array[1..MAX_CUSTOM_FILES] of CRC32_t;
  FilesDownloaded: Byte;
 end;

const
 SIGNONS = 3;
 MAX_DLIGHTS = 32;
 MAX_ELIGHTS = 64;

 MAX_DEMOS = 32;
 MAX_DEMONAME = 32;

type
 CActive_t = (ca_dedicated,     // A dedicated server with no ability to start a client
              ca_disconnected,  // Full screen console with no connection
              ca_connecting,    // Challenge requested, waiting for response or to resend connection request.
              ca_connected,     // valid netcon, talking to a server, waiting for server data
              ca_active);       // d/l complete, ready game views should be displayed

type
 client_static_s = ^client_static_t;
 client_static_t = record
  State: cactive_t;
//  Netchan: netchan_t;
   
 end;

// convar.h
const
  COMMAND_COMPLETION_MAXITEMS = 64;
  COMMAND_COMPLETION_ITEM_LENGTH = 64;

type
  PCommandsCompletionArray = ^TCommandsCompletionArray;
  TCommandsCompletionArray = array[0..COMMAND_COMPLETION_MAXITEMS - 1] of array[0..COMMAND_COMPLETION_ITEM_LENGTH - 1] of AnsiChar;
  FnCommandCompletionCallback = function(Partial: PAnsiChar; Commands: TCommandsCompletionArray): LongInt; cdecl; // cdecl?

type
  PConCommandBase = ^ConCommandBase;
  ConCommandBase = record {thiscall}
    Create: procedure(B: Boolean); stdcall;
    IsCommand: function: Boolean; stdcall;
    IsBitSet: function(Flag: LongWord): Boolean; stdcall;
    AddFlags: procedure(Flag: LongWord); stdcall;
    GetName: function: PAnsiChar; stdcall;
    GetHelpText: function: PAnsiChar; stdcall;
    GetNext: function: PConCommandBase; stdcall;
    SetNext: procedure(Next: PConCommandBase); stdcall;
    IsRegistered: function: Boolean; stdcall;
  end;

type
  PConCommandBase2 = ^ConCommandBase2; // newer game builds
  ConCommandBase2 = record {thiscall}
    Def: ConCommandBase;

    GetCommands: function: PConCommandBase2; stdcall;
    AddToList: procedure(const Variable: ConCommandBase); stdcall;
    RemoveFlaggedCommands: procedure(Flag: LongInt); stdcall;
    RevertFlaggedCvars: procedure(Flag: LongInt); stdcall;
    FindCommand: function(Name: PAnsiChar): PConCommandBase2; stdcall;
  end;

type
  PConCommand = ^ConCommand;
  ConCommand = record
    Parent: ConCommandBase;

    Destroy: procedure; stdcall;
    IsCommand: function: Boolean; stdcall;
    AutoCompleteSuggest: function(Partial: PAnsiChar; Commands: TCommandsCompletionArray): LongInt; stdcall;
    CanAutoComplete: function: Boolean; stdcall;
    Dispatch: procedure; stdcall;
  end;

  PConCommand2 = ^ConCommand2;
  ConCommand2 = record
    Parent: ConCommandBase2;

    Destroy: procedure; stdcall;
    IsCommand: function: Boolean; stdcall;
    AutoCompleteSuggest: function(Partial: PAnsiChar; Commands: TCommandsCompletionArray): LongInt; stdcall;
    CanAutoComplete: function: Boolean; stdcall;
    Dispatch: procedure; stdcall;
  end;

// iconvar.h
const
 FCVAR_NONE             = 0;
 FCVAR_UNREGISTERED     = 1 shl 0;
 FCVAR_DEVELOPMENTONLY  = 1 shl 1;
 FCVAR_GAMEDLL          = 1 shl 2;
 FCVAR_CLIENTDLL        = 1 shl 3;
 FCVAR_HIDDEN           = 1 shl 4;

 FCVAR_PROTECTED        = 1 shl 5;
 FCVAR_SPONLY           = 1 shl 6;
 FCVAR_ARCHIVE          = 1 shl 7;
 FCVAR_NOTIFY           = 1 shl 8;
 FCVAR_USERINFO         = 1 shl 9;
 FCVAR_CHEAT            = 1 shl 14;

 FCVAR_PRINTABLEONLY    = 1 shl 10;
 FCVAR_UNLOGGED         = 1 shl 11;
 FCVAR_NEVER_AS_STRING  = 1 shl 12;

 FCVAR_REPLICATED       = 1 shl 13;
 FCVAR_SERVER           = FCVAR_REPLICATED;
 FCVAR_DEMO             = 1 shl 16;
 FCVAR_DONTRECORD       = 1 shl 17;
 FCVAR_RELOAD_MATERIALS = 1 shl 20;
 FCVAR_RELOAD_TEXTURES  = 1 shl 21;

 FCVAR_NOT_CONNECTED    = 1 shl 22;
 FCVAR_MATERIAL_SYSTEM_THREAD = 1 shl 23;
 FCVAR_ARCHIVE_XBOX     = 1 shl 24;

 FCVAR_ACCESSIBLE_FROM_THREADS  = 1 shl 25;
 FCVAR_SERVER_CAN_EXECUTE       = 1 shl 28;
 FCVAR_SERVER_CANNOT_QUERY      = 1 shl 29;
 FCVAR_CLIENTCMD_CAN_EXECUTE    = 1 shl 30;

 FCVAR_MATERIAL_THREAD_MASK     = FCVAR_RELOAD_MATERIALS or FCVAR_RELOAD_TEXTURES or FCVAR_MATERIAL_SYSTEM_THREAD;

type
  PIConVar = ^IConVar;
  IConVar = record
    SetValueAsString: procedure(Value: PAnsiChar); stdcall;
    SetValueAsFloat: procedure(Value: Single); stdcall;
    SetValueAsInteger: procedure(Value: LongInt); stdcall;

    GetName: function: PAnsiChar; stdcall;

    IsFlagSet: function(Flag: LongInt): Boolean; stdcall;
  end;

type
 PConVarTable = ^ConVarTable;
 ConVarTable = record
   BaseClass: ConCommandBase;

   // ...
 end;

 PConVar = ^ConVar; // <!> need to fix this goddamn class
 ConVar = record
   VTable: PConVarTable; // 0

   Parent: PConVar; // 4
   Unk01: LongWord; // 8
   Name, Desc: PAnsiChar; // 12, 16
   Flags: LongWord; // 20
   Callback: Pointer; // 24
   Default: PAnsiChar; // 28
   Value: PAnsiChar; // 32
   Unk03: LongWord; // 36
 end;

type
 FnChangeCallback_s = ^FnChangeCallback_t;
 FnChangeCallback_t = procedure(Variable: PIConVar; OldStrValue: PAnsiChar; OldFloatValue: Single); stdcall;

// IAppSystem.h
type
 TInitReturnVal = (INIT_FAILED = 0, INIT_OK, INIT_LAST_VAL);

type
 PIAppSystem = ^IAppSystem;
 IAppSystem = record
  Connect: function(const Factory: CreateInterfaceFn): Boolean; stdcall;
  Disconnect: procedure; stdcall;

  QueryInterface: function(const InterfaceName: PAnsiChar): Pointer; stdcall;

  Init: function: TInitReturnVal; stdcall;
  Shutdown: procedure; stdcall;
 end;

// icvar.h
const
 CVAR_QUERY_INTERFACE_VERSION001: PAnsiChar = 'VCvarQuery001';
 CVAR_INTERFACE_VERSION003: PAnsiChar = 'VEngineCvar003';
 CVAR_INTERFACE_VERSION004: PAnsiChar = 'VEngineCvar004';

type
 PCVarDLLIdentifier = ^TCVarDLLIdentifier;
 TCVarDLLIdentifier = LongInt;

type
 PIConsoleDisplayFunc = ^IConsoleDisplayFunc;
 IConsoleDisplayFunc = record
  ColorPrint: procedure(const Clr: Pointer; Message: PAnsiChar); stdcall;
  Print: procedure(const Message: PAnsiChar); stdcall;
  DPrint: procedure(const Message: PAnsiChar); stdcall;
 end;

type
 PICvarQuery = ^ICvarQuery;
 ICvarQuery = record
  Parent: IAppSystem;
  AreConVarsLinkable: function(Child, Parent: Pointer): Boolean; stdcall; // todo: Pointer = ConVar
 end;

type
 PICvar004Table = ^ICvar004Table;
 ICvar004Table = record {thiscall}
   Parent: IAppSystem;

   AllocateDLLIdentifier: function: TCVarDLLIdentifier; stdcall; // 20

   // Pointer = ConCommandBase
   RegisterConCommand: procedure(CommandBase: Pointer); stdcall; // todo: CommandBase = ConCommandBase
   UnregisterConCommand: procedure(CommandBase: Pointer); stdcall; // todo: CommandBase = ConCommandBase
   UnregisterConCommands: procedure(ID: TCVarDLLIdentifier); stdcall;

   GetCommandLineValue: function(const VariableName: PAnsiChar): PAnsiChar; stdcall;

   // Pointer = ConCommandBase
   FindCommandBase: function(const Name: PAnsiChar): Pointer; stdcall;
   FindCommandBase_: function(const Name: PAnsiChar): Pointer; stdcall;

   FindVar: function(const VarName: PAnsiChar): Pointer; stdcall; // todo: result = ConVar
   FindVar_: function(const VarName: PAnsiChar): Pointer; stdcall; // todo: result = ConVar

   FindCommand: function(const Name: PAnsiChar): Pointer; stdcall; // todo: result = ConCommand
   FindCommand2: function(const Name: PAnsiChar): Pointer; stdcall; // todo: result = ConCommand

   GetCommands: function: Pointer; stdcall; // todo: result = ConCommandBase
   GetCommands2: function: Pointer; stdcall; // todo: result = ConCommandBase

   InstallGlobalChangeCallback: procedure(Callback: FnChangeCallback_t); stdcall;
   RemoveGlobalChangeCallback: procedure(Callback: FnChangeCallback_t); stdcall;
   CallGlobalChangeCallbacks: procedure(Variable: PIConVar; OldStrValue: PAnsiChar; OldFloatValue: Single); stdcall;

   InstallConsoleDisplayFunc: procedure(DisplayFunc: PIConsoleDisplayFunc); stdcall;
   RemoveConsoleDisplayFunc: procedure(DisplayFunc: PIConsoleDisplayFunc); stdcall;

   ConsoleColorPrintf: procedure(Clr: Pointer; Format: PAnsiChar); cdecl; // todo: Clr: Color
   ConsolePrintf: procedure(Format: PAnsiChar); cdecl;
   ConsoleDPrintf: procedure(Format: PAnsiChar); cdecl;

   RevertFlaggedConVars: procedure(Flag: LongInt); stdcall;

   InstallCVarQuery: procedure(Query: PICvarQuery); stdcall;
 end;

 PICvar004 = ^ICvar004;
 ICvar004 = record
   Table: PICvar004Table;
   // ...
 end;

type
 PICvar003Table = ^ICvar003Table;
 ICvar003Table = record
   Parent: IAppSystem;

   RegisterConCommandBase: procedure(CommandBase: Pointer); stdcall; // todo: CommandBase = ConCommandBase

   GetCommandLineValue: function(VariableName: PAnsiChar): PAnsiChar; stdcall;

   FindVar: function(VarName: PAnsiChar): Pointer; stdcall;// todo: result = PConVar
   FindVar_: function(VarName: PAnsiChar): Pointer; stdcall;// todo: result = PConVar

   GetCommand: function: Pointer; stdcall; // todo: result = ConCommandBase

   UnlinkVariables: procedure(Flag: LongInt); stdcall;

   InstallGlobalChangeCallback: procedure(Callback: FnChangeCallback_t); stdcall;
   CallGlobalChangeCallback: procedure(Variable: Pointer; OldString: PAnsiChar); stdcall; // todo: var = PConVar
 end;

 PICvar003 = ^ICvar003;
 ICvar003 = record
   Table: PICvar003Table;
   // ...
 end;

// ienginevgui.h
type
 VGuiPanel_t = (PANEL_ROOT = 0, PANEL_GAMEUIDLL, PANEL_CLIENTDLL, PANEL_TOOLS, PANEL_INGAMESCREENS, PANEL_GAMEDLL, PANEL_CLIENTDLL_TOOLS);
 PaintMode_t = (PAINT_UIPANELS = 1 shl 0, PAINT_INGAMEPANELS = 1 shl 1);

type
 VEngineVgui001 = record
  Create: procedure; stdcall;
  Destroy: procedure; stdcall;
  GetPanel: function(PanelType: VGuiPanel_t): Pointer; stdcall; // todo: result = VPANEL
  Init: procedure; stdcall;
  Connect: procedure; stdcall;
  Shutdown: procedure; stdcall;

  // ...
 end;

type
 PIRecipientFilter = ^IRecipientFilter;
 IRecipientFilter = record
  Destroy: procedure; stdcall;
  IsReliable: function: Boolean;
  IsInitMessage: function: Boolean;
  GetRecipientCount: function: LongInt; stdcall;
  GetRecipientIndex: function(Slot: LongInt): LongInt; stdcall;
 end;

//
const
  VENGINE_LAUNCHER_API_VERSION004: PAnsiChar = 'VENGINE_LAUNCHER_API_VERSION004';

type
  StartupInfo_t = record
    m_pInstance: Pointer;
    m_pBaseDirectory: PAnsiChar;
    m_pInitialMod: PAnsiChar;
    m_pInitialGame: PAnsiChar;
    m_pParentAppSystemGroup: Pointer; // todo: CAppSystemGroup
    m_bTextMode: Boolean;
  end;                        

  PIEngineAPI004 = ^VEngineAPI004;
  VEngineAPI004 = record
    Parent: IAppSystem;

    SetStartupInfo: procedure(const Info: StartupInfo_t); stdcall;
    Run: procedure; stdcall;
    SetEngineWindow: procedure(HWND: Pointer); stdcall;
    PostConsoleCommand: procedure(ConsoleCommand: PAnsiChar); stdcall;
    IsRunningSimulation: function: Boolean; stdcall;
    ActivateSimulation: procedure; stdcall;
    SetMap: procedure(MapName: PAnsiChar); stdcall;
  end;

// reverse engineering
type
  PDLInfo = ^TDLInfo;
  TDLInfo = record
    Unk01, Unk02, Unk03, Unk04, Unk05: LongWord; // 0, 4, 8, 12, 16
    DownloadLocation: array[0..255] of AnsiChar; // 20
    GameDirectory: array[0..255] of AnsiChar; // 276
    FileName: array[0..255] of AnsiChar; // 532
    ServerAddress: array[0..255] of AnsiChar; // 788
    LastModified: array[0..255] of AnsiChar; // 1044 (var)
    Unk06, Unk07, Unk08, Unk09: LongWord; // 1300, 1556, 1560, 1564
    hConnect: THandle; // 1568
    Unk10, Unk11, Unk12, Unk13, Unk14: LongWord; // 1568, 1572, 1576, 1580, 1584
  end;

type
  PDownloadSystem001 = ^DownloadSystem001;
  DownloadSystem001 = record
    Destroy: procedure(B: Boolean); stdcall;
    DownloadFile: procedure(DLInfo: TDLInfo); stdcall;
  end;

// baseclientstate.h
type
  PCBaseClientState = ^CBaseClientState;
  CBaseClientState = record

  end;

// ienginetool.h

// IGameConsole.h
const
  GAMECONSOLE_INTERFACE_VERSION003: PAnsiChar = 'GameConsole003'; // gameui.dll
  GAMECONSOLE_INTERFACE_VERSION004: PAnsiChar = 'GameConsole004'; // gameui.dll

type
  PVGameConsole003 = ^VGameConsole003;
  VGameConsole003 = record
    Parent: IBaseInterface;

    Activate: procedure; stdcall;
    Initialize: procedure; stdcall;
    Hide: procedure; stdcall;
    Clear: procedure; stdcall;
    IsConsoleVisible: function: Boolean; stdcall;
    PrintF: procedure(Console: Pointer; const Msg: PAnsiChar); cdecl varargs;
    DPrintF: procedure(Console: Pointer; const Msg: PAnsiChar); cdecl varargs;
    _PrintF: procedure(Console: Pointer; Unk: Pointer; const Msg: PAnsiChar); cdecl varargs; // ???
    SetParent: procedure(Parent: Pointer); stdcall;
  end;

 PIGameConsole003 = ^IGameConsole003;
 IGameConsole003 = record
   VTable: PVGameConsole003;
   // ...
 end;

type
  PVGameConsole004 = ^VGameConsole004;
  VGameConsole004 = record
    Parent: IBaseInterface;

    Activate: procedure; stdcall;
    Initialize: procedure; stdcall;
    Hide: procedure; stdcall;
    Clear: procedure; stdcall;
    IsConsoleVisible: function: Boolean; stdcall;
    SetParent: procedure(Parent: LongInt); stdcall;
  end;

 PIGameConsole004 = ^IGameConsole004;
 IGameConsole004 = record
   VTable: PVGameConsole004;
   // ...
 end;

// iavi.h
const
  AVI_INTERFACE_VERSION001 = 'VAvi001'; // valve_avi.dll

type
  AVIHandle_t = THandle;
  AVIMaterial_t = Word;

  AVIParams_t = record

  end;

type
  PIAvi = ^IAvi;
  IAvi = record
    Parent: IAppSystem;

    SetMainWindow: procedure(HWND: Pointer); stdcall;

    StartAVI: function(const Params: AVIParams_t): AVIHandle_t; stdcall;
    FinishAVI: procedure(Handle: AVIHandle_t); stdcall;

    AppendMovieSound: procedure(h: AVIHandle_t; Buf: Word; BufSize: LongWord); stdcall;
    AppendMovieFrame: procedure(h: AVIHandle_t; const RGBData: BGR888_t); stdcall;

    CreateAVIMaterial: function(MaterialName, FileName, PathID: PAnsiChar): AVIMaterial_t; stdcall;
    DestroyAVIMaterial: procedure(Material: AVIMaterial_t); stdcall;

    SetTime: procedure(Material: AVIMaterial_t; Time: Single); stdcall;

    GetMaterial: function(Material: AVIMaterial_t): Pointer; stdcall; // todo: Result = PIMaterial
    GetTexCoordRange: procedure(Material: AVIMaterial_t; var MaxU, MaxV: Single); stdcall;
    GetFrameSize: procedure(Material: AVIMaterial_t; var Width, Height); stdcall;
    GetFrameRate: function(Material: AVIMaterial_t): LongInt; stdcall;
    GetFrameCount: function(Material: AVIMaterial_t): LongInt; stdcall;
    SetFrame: procedure(Material: AVIMaterial_t; Frame: Single); stdcall;
  end;

type
  ClientRenderHandle_p = ^ClientRenderHandle_t;
  ClientRenderHandle_t = Word;
  ModelInstanceHandle_p = ^ModelInstanceHandle_t;
  ModelInstanceHandle_t = Word;

  ShadowType_t = (SHADOWS_NONE = 0, SHADOWS_SIMPLE, SHADOWS_RENDER_TO_TEXTURE, SHADOWS_RENDER_TO_TEXTURE_DYNAMIC, SHADOWS_RENDER_TO_DEPTH_TEXTURE);
  ClientShadowHandle_t = Word;

const
  INVALID_CLIENT_RENDER_HANDLE = ClientRenderHandle_t(not 0);
  MODEL_INSTANCE_INVALID = ModelInstanceHandle_t(not 0);

const
  CLIENTSHADOW_INVALID_HANDLE = ClientShadowHandle_t(0);

type
  PICollideable = ^ICollideable;
  PIClientUnknown = ^IClientUnknown;
  PIClientNetworkable = ^IClientNetworkable;
  PIClientRenderable = ^IClientRenderable;

// iclientnetworkable.h
  ShouldTransmitState_t = (SHOULDTRANSMIT_START = 0, SHOULDTRANSMIT_END);
  DataUpdateType_t = (DATA_UPDATE_CREATED = 0, DATA_UPDATE_DATATABLE_CHANGED);

  IClientNetworkable = record
    GetIClientUnknown: function: PIClientUnknown; stdcall;
    Release: procedure; stdcall;
    GetClientClass: function: Pointer; // todo: Result = PClientClass
    NotifyShouldTransmit: procedure(State: ShouldTransmitState_t); stdcall;

    OnPreDataChanged: procedure(UpdateType: DataUpdateType_t); stdcall;
    OnDataChanged: procedure(UpdateType: DataUpdateType_t); stdcall;

    PreDataUpdate: procedure(UpdateType: DataUpdateType_t); stdcall;
    PostDataUpdate: procedure(UpdateType: DataUpdateType_t); stdcall;

    IsDormant: function: Boolean; stdcall;

    entindex: function: LongInt; stdcall;

    ReceiveMessage: function: Pointer; stdcall;

    GetDataTableBasePtr: function: Pointer; stdcall;

    SetDestroyedOnRecreateEntities: procedure; stdcall;
  end;

// ihandleentity.h
  PIHandleEntity = ^IHandleEntity;
  IHandleEntity = record
    Destroy: procedure; stdcall;
    SetRefEHandle: procedure(Handle: Pointer); stdcall; // todo: CBaseHandle
    GetRefEHandle: function: Pointer; stdcall; // todo: CBaseHandle
  end;


// iclientunknown.h
  IClientUnknown = record
    Parent: IHandleEntity;

    GetCollideable: function: PICollideable; stdcall;
    GetClientNetworkable: function: PIClientNetworkable; stdcall;
    GetClientRenderable: function: PIClientRenderable; stdcall;
    GetIClientEntity: function: Pointer; stdcall; // todo: PIClientEntity
    GetBaseEntity: function: Pointer; stdcall; // todo: PC_BaseEntity
    GetClientThinkable: function: Pointer; stdcall; // todo: PIClientThinkable
  end;

// ICollienable.h
  ICollideable = record
    GetEntityHandle: function: PIHandleEntity; stdcall;
    OBBMins: function: PVector; stdcall;
    OBBMaxs: function: PVector; stdcall;
    WorldSpaceTriggerBounds: procedure(var VecWorldMins, pVecWorldMaxs: Vector); stdcall;
    TestCollision: function(const Ray: Ray_t; ContentsMask: LongWord; Trace: Pointer): Boolean; stdcall; // todo: Trace: Pointer
    TestHitboxes: function(const Ray: Ray_t; ContentsMask: LongWord; Trace: Pointer): Boolean; stdcall; // todo: Trace: Pointer
    GetCollisionModelIndex: function: LongInt; stdcall;
    GetCollisionModel: function: model_s; stdcall;
    GetCollisionOrigin: function: PVector; stdcall;
    GetCollisionAngles: function: Pointer; stdcall; // todo: Result = PQAngle
    CollisionToWorldTransform: function: Pointer; stdcall; // todo: Result = matrix3x4_p
    GetSolid: function: SolidType_t; stdcall;
    GetSolidFlags: function: LongInt; stdcall;
    GetIClientUnknown: function: PIClientUnknown; stdcall;
    GetCollisionGroup: function: LongInt; stdcall;
 end;

  IClientRenderable = record
    GetIClientUnknown: function: PIClientUnknown; stdcall;
    GetRenderOrigin: function: PVector; stdcall;
    GetRenderAngles: function: Pointer; stdcall; // todo: Result = QAngle
    ShouldDraw: function: Boolean; stdcall;
    IsTransparent: function: Boolean; stdcall;
    UsesPowerOfTwoFrameBufferTexture: function: Boolean; stdcall;
    UsesFullFrameBufferTexture: function: Boolean; stdcall;
    GetShadowHandle: function: ClientShadowHandle_t; stdcall;
    RenderHandle: function: ClientRenderHandle_p; stdcall;
    GetModel: function: model_s; stdcall;
    DrawModel: function(Flags: LongInt): LongInt; stdcall;
    GetBody: function: LongInt; stdcall;
    ComputeFxBlend: procedure; stdcall;
    GetFxBlend: function: LongInt; stdcall;
    GetColorModulation: procedure(var Color: Single); stdcall;
    LODTest: function: Boolean; stdcall;
    SetupBones: function(BoneToWorldOut: Pointer; MaxBones, BoneBask, CurrentTime: LongInt): Boolean; stdcall; // todo: matrix3x4_p
    SetupWeights: function(const BoneToWorld: Pointer; FlexWeightCount: LongInt; var FlexWeight, FlexDelayedWeights: Single): Boolean; stdcall; // todo: matrix3x4_p
    DoAnimationEvents: procedure; stdcall;
    GetPVSNotifyInterface: function: Pointer; stdcall; // todo: Result = PIPVSNotiy
    GetRenderBounds: procedure(var Mins, Maxs: Vector); stdcall;
    GetRenderBoundsWorldspace: procedure(var Mins, Maxs: Vector); stdcall;
    GetShadowRenderBounds: procedure(var Mins, Maxs: Vector; ShadowType: ShadowType_t); stdcall;
    ShouldReceiveProjectedTextures: function(Flags: LongInt): Boolean; stdcall;
    GetShadowCastDistance: function(var Dist: Single; ShadowType: ShadowType_t): Boolean; stdcall;
    GetShadowCastDirection: function(var Direction: Vector; ShadowType: ShadowType_t): Boolean; stdcall;
    IsShadowDirty: function: Boolean; stdcall;
    MarkShadowDirty: procedure(Dirty: Boolean); stdcall;
    GetShadowParent: function: PIClientRenderable; stdcall;
    FirstShadowChild: function: PIClientRenderable; stdcall;
    NextShadowPeer: function: PIClientRenderable; stdcall;
    ShadowCastType: function: ShadowType_t; stdcall;
    CreateModelInstance: procedure; stdcall;
    GetModelInstance: function: ModelInstanceHandle_t; stdcall;
    RenderableToWorldTransform: function: Pointer; stdcall; // todo: matrix3x4_p
    LookupAttachment: function(AttachmentName: PAnsiChar): LongInt; stdcall;
    GetAttachment: function(Number: LongInt; var Origin: Vector; Angles: Pointer): Boolean; stdcall; // todo: Angles = PQAngle
    GetAttachment2: function(Number: LongInt; Matrix: Pointer): Boolean; stdcall; // todo: Matrix = matrix3x4_p
    GetRenderClipPlane: function: Single; stdcall;
    GetSkin: function: Single; stdcall;
    IsTwoPass: function: Boolean; stdcall;
    OnThreadedDrawSetup: procedure; stdcall;
    UsesFlexDelayedWeights: function: Boolean; stdcall;
    RecordToolMessage: procedure; stdcall;
  end;

// iclientrenderable.h
type
  PIPVSNotify = ^IPVSNotify;
  IPVSNotify = record
    OnPVSStatusChanged: procedure(InPVS: Boolean); stdcall;
  end;

// itoolentity.h
const
  HTOOLHANDLE_INVALID = 0;

type
  HTOOLHANDLE = LongWord;
  EntitySearchResult = Pointer;

  PIClientTools001 = ^IClientTools001;
  IClientTools001 = record
    Parent: IBaseInterface;

    AttachToEntity: function(EntityToAttach: EntitySearchResult): HTOOLHANDLE; stdcall;
    DetachFromEntity: procedure(EntityToDetach: EntitySearchResult); stdcall;
    IsValidHandle: function(Handle: HTOOLHANDLE): Boolean; stdcall;
    GetNumRecordables: function: LongInt; stdcall;
    GetRecordable: function(Index: LongInt): HTOOLHANDLE; stdcall;
    NextEntity: function(CurrentEnt: EntitySearchResult): EntitySearchResult; stdcall;
    // FirstEntity?
    SetEnabled: procedure(Handle: HTOOLHANDLE; Enabled: Boolean); stdcall;
    SetRecording: procedure(Handle: HTOOLHANDLE; Enabled: Boolean); stdcall;
    ShouldRecord: function(Handle: HTOOLHANDLE): Boolean; stdcall;
    GetToolHandleForEntityByIndex: function(EntIndet: LongInt): HTOOLHANDLE; stdcall;
    GetModelIndex: function(Handle: HTOOLHANDLE): LongInt; stdcall;
    GetModelName: function(Handle: HTOOLHANDLE): LongInt; stdcall;
    GetClassname: function(Handle: HTOOLHANDLE): LongInt; stdcall;
    AddClientRenderable: procedure(Renderable: PIClientRenderable; RenderGroup: LongInt); stdcall;
    RemoveClientRenderable: procedure(Renderable: PIClientRenderable); stdcall;
    SetRenderGroup: procedure(Renderable: PIClientRenderable; RenderGroup: LongInt); stdcall;
    MarkClientRenderableDirty: procedure(Renderable: PIClientRenderable); stdcall;
    UpdateProjectedTexture: procedure(h: ClientShadowHandle_t; Force: Boolean); stdcall;

    DrawSprite: function(Renderable: PIClientRenderable; Scale, Frame: Single; RenderMode, RenderFX: LongInt; Color: Pointer; ProxyRadius: Single; var VisHandle: LongInt): Boolean; stdcall; // todo: Color = PColor
    GetLocalPlayer: function: EntitySearchResult; stdcall;
    GetLocalPlayerEyePosition: function(var Org: Vector; Ang: Pointer; var Fov: Single): Boolean; stdcall; // todo: Ang = PQAngle
    CreateShadow: function(Handle: Pointer; Flags: LongInt): ClientShadowHandle_t; stdcall; // todo: Handle = CBaseHandle
    DestroyShadow: procedure(h: ClientShadowHandle_t); stdcall;
    CreateFlashlight: function(const LightState: Pointer): ClientShadowHandle_t; stdcall; // todo: FlashlightState_t
    DestroyFlashlight: procedure(h: ClientShadowHandle_t); stdcall;
    UpdateFlashlightState: procedure(h: ClientShadowHandle_t; LightState: Pointer); stdcall; // todo: LightState = FlashlightState_t
    AddToDirtyShadowList: procedure(h: ClientShadowHandle_t; Force: Boolean = False); stdcall;
    MarkRenderToTextureShadowDirty: procedure(h: ClientShadowHandle_t); stdcall;
    EnableRecordingMode: procedure(Enable: Boolean); stdcall;
    IsInRecordingMode: function: Boolean; stdcall;
    TriggerTempEntity: procedure(KeyValues: Pointer); stdcall; // todo: result = PKeyValues
    GetOwningWeaponEntIndex: function(EntIndex: LongInt): LongInt; stdcall;
    GetEntIndex: function(EntityToAttach: EntitySearchResult): LongInt; stdcall;
    FindGlobalFlexcontroller: function(Name: PAnsiChar): LongInt; stdcall;
    GetGlobalFlexControllerName: function(Idx: LongInt): PAnsiChar; stdcall;
    GetOwnerEntity: function(CurrentEnt: EntitySearchResult): EntitySearchResult; stdcall;
    IsPlayer: function(CurrentEnt: EntitySearchResult): Boolean; stdcall;
    IsBaseCombatCharacter: function(CurrentEnt: EntitySearchResult): Boolean; stdcall;
    IsNPC: function(CurrentEnt: EntitySearchResult): Boolean; stdcall;
    GetAbsOrigin: function(Handle: HTOOLHANDLE): PVector; stdcall;
    GetAbsAngles: function(Handle: HTOOLHANDLE): Pointer; stdcall; // todo: PGetAbsAngles
    ReloadParticleDefintions: procedure(FileName: PAnsiChar; BufData: Pointer; Len: LongInt); stdcall;
    PostToolMessage: procedure(KeyValues: Pointer); stdcall; // todo: PKeyValues
    EnableParticleSystems: procedure(Enable: Boolean); stdcall;
    IsRenderingThirdPerson: function: Boolean; stdcall;
  end;

const
  VCLIENTTOOLS_INTERFACE_VERSION001: PAnsiChar = 'VCLIENTTOOLS001';

// iserverenginetools.h
const
  VSERVERENGINETOOLS_INTERFACE_VERSION001: PAnsiChar = 'VSERVERENGINETOOLS001';

type
  PIServerEngineTools = ^IServerEngineTools;
  IServerEngineTools = record
    Parent: IBaseInterface;

    LevelInitPreEntityAllTools: procedure; stdcall;
    LevelInitPostEntityAllTools: procedure; stdcall;
    LevelShutdownPreEntityAllTools: procedure; stdcall;
    LevelShutdownPostEntityAllTools: procedure; stdcall;
    FrameUpdatePreEntityThinkAllTools: procedure; stdcall;
    FrameUpdatePostEntityThinkAllTools: procedure; stdcall;
    PreClientUpdateAllTools: procedure; stdcall;
    GetEntityData: function(ActualEntityData: PAnsiChar): PAnsiChar; stdcall;
    PreSetupVisibilityAllTools: procedure; stdcall;
    InToolMode: function: Boolean; stdcall;
  end;

// iclientenginetools.h
const
  VCLIENTENGINETOOLS_INTERFACE_VERSION001: PAnsiChar = 'VCLIENTENGINETOOLS001';

type
  PIClientEngineTools001 = ^IClientEngineTools001;
  IClientEngineTools001 = record
    LevelInitPreEntityAllTools: procedure; stdcall;
    LevelInitPostEntityAllTools: procedure; stdcall;
    LevelShutdownPreEntityAllTools: procedure; stdcall;
    LevelShutdownPostEntityAllTools: procedure; stdcall;
    PreRenderAllTools: procedure; stdcall;
    PostRenderAllTools: procedure; stdcall;
    PostToolMessage: procedure(Entity: HTOOLHANDLE; Msg: PAnsiChar); stdcall;
    AdjustEngineViewport: procedure(var X, Y, Widht, Height: LongInt); stdcall;
    SetupEngineView: function(var Origin: Vector; Angles: Pointer; var Fov: Single): Boolean; stdcall; // todo: Angles = PQAngles
    SetupAudioState: function(AudioState: AudioState_t): Boolean; stdcall;
    VGui_PreRenderAllTools: procedure(PaintMode: LongInt); stdcall;
    VGui_PostRenderAllTools: procedure(PaintMode: LongInt); stdcall;
    IsThirdPersonCamera: function: Boolean; stdcall;
    InToolMode: function: Boolean; stdcall;
  end;

const
  VTOOLFRAMEWORK_INTERFACE_VERSION002: PAnsiChar = 'VTOOLFRAMEWORKVERSION002';

type
  PIToolFrameworkInternal002 = ^IToolFrameworkInternal002;
  IToolFrameworkInternal002 = record
    Parrent: IAppSystem;

    ClientInit: function(ClientFactory: CreateInterfaceFn): Boolean; stdcall;
    ClientShutdown: procedure; stdcall;

    ClientLevelInitPreEntityAllTools: procedure; stdcall;
    ClientLevelInitPostEntityAllTools: procedure; stdcall;
    ClientLevelShutdownPreEntityAllTools: procedure; stdcall;
    ClientLevelShutdownPostEntityAllTools: procedure; stdcall;
    ClientPreRenderAllTools: procedure; stdcall;
    ClientPostRenderAllTools: procedure; stdcall;
    IsThirdPersonCamera: function: Boolean; stdcall;
    IsToolRecording: function: Boolean; stdcall;

    ServerInit: function(ServerFactory: CreateInterfaceFn): Boolean; stdcall;
    ServerShutdown: procedure; stdcall;

    ServerLevelInitPreEntityAllTools: procedure; stdcall;
    ServerLevelInitPostEntityAllTools: procedure; stdcall;
    ServerLevelShutdownPreEntityAllTools: procedure; stdcall;
    ServerLevelShutdownPostEntityAllTools: procedure; stdcall;
    ServerFrameUpdatePreEntityThinkAllTools: procedure; stdcall;
    ServerFrameUpdatePostEntityThinkAllTools: procedure; stdcall;
    ServerPreClientUpdateAllTools: procedure; stdcall;
    ServerPreSetupVisibilityAllTools: procedure; stdcall;

    CanQuit: function: Boolean; stdcall;

    PostInit: function: Boolean; stdcall;

    Think: procedure(FinalTick: Boolean); stdcall;

    PostMessage: procedure(Msg: Pointer); stdcall; // todo: Msg = PKeyValues

    GetSoundSpatialization: function(UserData, GUID: LongInt; Info: Pointer): Boolean; stdcall; // todo: Info = SpatializationInfo_p

    HostRunFrameBegin: procedure; stdcall;
    HostRunFrameEnd: procedure; stdcall;

    RenderFrameBegin: procedure; stdcall;
    RenderFrameEnd: procedure; stdcall;

    VGui_PreRenderAllTools: procedure(PaintMode: LongInt); stdcall;
    VGui_PostRenderAllTools: procedure(PaintMode: LongInt); stdcall;

    VGui_PreSimulateAllTools: procedure; stdcall;
    VGui_PostSimulateAllTools: procedure; stdcall;

    InToolMode: function: Boolean; stdcall;
    ShouldGameRenderView: function: Boolean; stdcall;

    LookupProxy: function(ProxyName: PAnsiChar): Pointer; stdcall; // todo: result = PIMaterialProxy

    GetToolCount: function: LongInt; stdcall;
    GetToolName: function(Index: LongInt): PAnsiChar; stdcall;
    SwitchToTool: procedure(Index: LongInt); stdcall;
    SwitchToTool2: function(ToolName: PAnsiChar): Pointer; stdcall; // todo: result = PIToolSystem
    IsTopmostTool: function(Sys: Pointer): Boolean; stdcall; // todo: sys = PIToolSystem
    GetToolSystem: function(Index: LongInt): Pointer; stdcall; // todo: result = PIToolSystem
    GetTopmostTool: function: Pointer; stdcall; // todo: result = PIToolSystem
  end;

const
  VENGINETOOL_INTERFACE_VERSION001: PAnsiChar = 'VENGINETOOL001';
  VENGINETOOL_INTERFACE_VERSION003: PAnsiChar = 'VENGINETOOL003';
  VENGINETOOLFRAMEWORK_INTERFACE_VERSION003: PAnsiChar = 'VENGINETOOLFRAMEWORK003';

type
  PLightList = ^TLightList;
  TLightList = array[0..MAX_DLIGHTS - 1] of dlight_t;

type
  PIEngineToolFramework003 = ^IEngineToolFramework003;
  IEngineToolFramework003 = record
    Parent: IBaseInterface;

    GetToolCount: function: LongInt; stdcall;
    GetToolName: function(Index: LongInt): PAnsiChar; stdcall;
    SwitchToTool: procedure(Index: LongInt); stdcall;

    IsTopmostTool: function(Sys: Pointer): Boolean; stdcall; // todo: Sys = PIToolSystem

    GetToolSystem: function(Index: LongInt): Pointer; stdcall; // todo: result = PIToolSystem
    GetTopmostTool: function(Index: LongInt): Pointer; stdcall; // todo: result = PIToolSystem

    ShowCursor: procedure(Show: Boolean); stdcall;
    IsCursorVisible: function: Boolean; stdcall;
  end;

  PIEngineTool003 = ^IEngineTool003;
  IEngineTool003 = record
    Parent: IEngineToolFramework003;

    GetServerFactory: procedure(var Factory: CreateInterfaceFn); stdcall;
    GetClientFactory: procedure(var Factory: CreateInterfaceFn); stdcall;

    GetSoundDuration: function(Name: PAnsiChar): Single; stdcall;
    IsSoundStillPlaying: function(GUID: LongInt): Boolean; stdcall;

    StartSound: function(UserData: LongInt; StaticSound: Boolean; EntIndex, Channel: LongInt;
                         Sample: PAnsiChar; Volume: Single; SoundLevel: Pointer; const Origin, Direction: Vector;
                         Flags: LongInt = 0; Pitch: LongInt = PITCH_NORM; UpdatePosition: Boolean = True;
                         Delay: Single = 0.0; SpeakerEntity: LongInt = -1): LongInt; stdcall;

    StopSoundByGuid: procedure(GUID: LongInt); stdcall;

    GetSoundDuration2: function(GUID: LongInt): Single; stdcall;

    IsLoopingSound: function(GUID: LongInt): Boolean; stdcall;
    ReloadSound: procedure(Sample: PAnsiChar); stdcall;
    StopAllSounds: procedure; stdcall;
    GetMono16Samples: function(Name: PAnsiChar; SampleList: Pointer): Single; stdcall; // todo: SampleList = CUtlVector< short >&
    SetAudioState: procedure(const AudioState: AudioState_t); stdcall;

    Command: procedure(Cmd: PAnsiChar); stdcall;
    Execute: procedure; stdcall;

    GetCurrentMap: function: PAnsiChar; stdcall;
    ChangeToMap: procedure(MapName: PAnsiChar); stdcall;
    IsMapValid: function(MapName: PAnsiChar): Boolean; stdcall;

    RenderView: procedure(View: Pointer; Flags: LongInt; WhatToRender: LongInt); stdcall; // todo: View = CViewSetup

    IsInGame: function: Boolean; stdcall; // Result := CState = 5;
    IsConnected: function: Boolean; stdcall; // Result := CState in [1..4];

    GetMaxClients: function: LongInt; stdcall;

    IsGamePaused: function: Boolean; stdcall;
    SetGamePaused: procedure(Paused: Boolean); stdcall;

    GetTimescale: function: Single; stdcall;
    SetTimescale: procedure(Scale: Single); stdcall;

    GetRealTime: function: Single; stdcall;
    GetRealFrameTime: function: Single; stdcall;

    Time: function: Single; stdcall;

    HostFrameTime: function: Single; stdcall;
    HostTime: function: Single; stdcall;
    HostTick: function: LongInt; stdcall;
    HostFrameCount: function: LongInt; stdcall;

    ServerTime: function: Single; stdcall;
    ServerFrameTime: function: Single; stdcall;
    ServerTick: function: LongInt; stdcall;
    ServerTickInterval: function: Single; stdcall;

    ClientTime: function: Single; stdcall;
    ClientFrameTime: function: Single; stdcall;
    ClientTick: function: LongInt; stdcall;

    SetClientFrameTime: procedure(FrameTime: Single); stdcall;

    ForceUpdateDuringPause: procedure; stdcall;
    GetModel: function(Entity: HTOOLHANDLE): model_s; stdcall;
    GetStudioModel: function(Entity: HTOOLHANDLE): Pointer; stdcall; // todo: Result = ^studiohdr_t

    Con_NPrintf: procedure(Pos: LongInt; Format: PAnsiChar); cdecl varargs;
    Con_NXPrintf: procedure(Info: con_nprint_s; Format: PAnsiChar); cdecl varargs;

    GetGameDir: procedure(GetGameDir: PAnsiChar; MaxLength: LongInt); stdcall;

    GetScreenSize: procedure(var Width, Height: LongInt); stdcall;

    SetMainView: procedure(const VecOrigin: Vector; const Angles: Pointer); stdcall; // todo: Angles = ^QAngle

    GetPlayerView: function(PlayerView: Pointer; X, Y, W, H: LongInt): Boolean; stdcall; // todo: PlayerView = ^CViewSetup

    CreatePickingRay: procedure(ViewSetup: Pointer; X, Y: LongInt; const Org, Forward: Vector); stdcall; // todo: viewsetup = ^CViewSetup

    PrecacheSound: function(Name: PAnsiChar; Preload: Boolean = False): Boolean; stdcall;
    PrecacheModel: function(Name: PAnsiChar; Preload: Boolean = False): Boolean; stdcall;

    InstallQuitHandler: procedure(UserName: PAnsiChar; Width, Height: LongInt); stdcall;
    TakeTGAScreenShot: procedure(FileName: PAnsiChar; Width, Height: LongInt); stdcall;

    ForceSend: procedure; stdcall;

    IsRecordingMovie: function: Boolean; stdcall;

    StartMovieRecording: procedure(MovieParams: Pointer); stdcall; // todo: MovieParams = KeyValues
    EndMovieRecording: procedure; stdcall;
    CancelMovieRecording: procedure; stdcall;
    GetRecordingAVIHandle: function: AVIHandle_t; stdcall;

    StartRecordingVoiceToFile: procedure(FileName, PathID: PAnsiChar); stdcall;
    StopRecordingVoiceToFile: procedure; stdcall;

    IsVoiceRecording: function: Boolean; stdcall;

    TraceRay: procedure(const Ray: Ray_t; Mask: LongWord; TraceFilter: Pointer; Trace: Pointer); stdcall; // todo: TraceFilter = ^ITraceFilter; Trace = ^CBaseTrace

    TraceRayServer: procedure(const Ray: Ray_t; Mask: LongWord; TraceFilter: Pointer; Trace: Pointer); stdcall; // todo: TraceFilter = ^ITraceFilter; Trace = ^CBaseTrace

    IsConsoleVisible: function: Boolean; stdcall;

    GetPointContents: function(var VecPosition: Vector): LongInt; stdcall;

    GetActiveDLights: function(List: PLightList): LongInt; stdcall;
    GetLightingConditions: function(const VecPosition: Vector; const Colors: Vector; MaxLocalLights: LongInt; LocalLight: Pointer): LongInt; stdcall; // todo: LocalLight = ^LightDesc_t;
    GetWorldToScreenMatrixForView: procedure(View: Pointer; Matrix: Pointer); stdcall; // TODO: View = ^CViewSetup; Matrix = ^VMatrix

    CreatePartitionHandle: function(Entity: PIHandleEntity; ListMask: SpatialPartitionListMask_t; const Mins, Maxs: Vector): SpatialPartitionHandle_t; stdcall;
    DestroyPartitionHandle: procedure(Particion: SpatialTempHandle_t); stdcall;
    InstallPartitionQueryCallback: procedure(Query: Pointer); stdcall; // Query = ^IPartitionQueryCallback
    RemovePartitionQueryCallback: procedure(Query: Pointer); stdcall;
    ElementMoved: procedure(Handle: SpatialTempHandle_t; const Mins, Maxs: Vector); stdcall;
  end;

// IGameUIFuncs.h
const
  VENGINE_GAMEUIFUNCS_VERSION005: PAnsiChar = 'VENGINE_GAMEUIFUNCS_VERSION005';

type
  PIGameUIFuncs = ^IGameUIFuncs;
  IGameUIFuncs = record
    IsKeyDown: function(KeyName: PAnsiChar; var IsDown: Boolean): Boolean; stdcall;
    GetBindingForButtonCode: function(Code: ButtonCode_s): PAnsiChar; stdcall;
    GetButtonCodeForBind: function(Bind: PAnsiChar): ButtonCode_t; stdcall;
    GetVideoModes: procedure(ListStart: Pointer; var Count: LongInt); stdcall; // todo: ListStart = ^^vmode_s
    SetFriendsID: procedure(FriendsID: LongWord; FriendsName: PAnsiChar); stdcall;
    GetDesktopResolution: procedure(var Widht, Height: LongInt); stdcall;
    IsConnectedToVACSecureServer: function: Boolean; stdcall;
  end;

// eiface.h
const
  INTERFACEVERSION_VENGINESERVER015: PAnsiChar = 'VEngineServer015';
  INTERFACEVERSION_VENGINESERVER021: PAnsiChar = 'VEngineServer021';

type
 PVEngineServer021 = ^VEngineServer021;
 VEngineServer021 = record
  ChangeLevel: procedure(S1, S2: PAnsiChar); stdcall; { userpurge (a1<sil>) }
  IsMapValid: function(FileName: PAnsiChar): LongInt; stdcall;
  IsDedicatedServer: function: LongInt; stdcall;
  IsInEditMode: function: LongInt; stdcall;
  PrecacheModel: function(Name: PAnsiChar; Preload: Boolean = False): LongInt; stdcall;
  PrecacheSentenceFile: function(Name: PAnsiChar; Preload: Boolean = False): LongInt; stdcall;
  PrecacheDecal: function(Name: PAnsiChar; Preload: Boolean = False): LongInt; stdcall;
  PrecacheGeneric: function(Name: PAnsiChar; Preload: Boolean = False): LongInt; stdcall;
  IsModelPrecached: function(Name: PAnsiChar): Boolean; stdcall;
  IsDecalPrecached: function(Name: PAnsiChar): Boolean; stdcall;
  IsGenericPrecached: function(Name: PAnsiChar): Boolean; stdcall;
  GetClusterForOrigin: function(const Org: Vector): LongInt; stdcall;
  GetPVSForCluster: function(Cluster: LongInt; OutputPVSLength: LongInt; OutputPVS: PAnsiChar): LongInt; stdcall;
  CheckOriginInPVS: function(const Org: Vector; CheckPVS: PAnsiChar): Boolean; stdcall;
  CheckBoxInPVS: function(const Mins, Maxs: Vector; CheckPVS: PAnsiChar): Boolean; stdcall;
  GetPlayerUserId: function(const E: edict_t): LongInt; stdcall;
  GetPlayerNetworkIDString: function(const E: edict_t): PAnsiChar; stdcall;
  GetEntityCount: function: LongInt; stdcall;
  IndexOfEdict: function(const Edict: edict_t): LongInt; stdcall;
  PEntityOfEntIndex: function(EntIndex: LongInt): edict_s; stdcall;
  GetPlayerNetInfo: function(PlayerIndex: LongInt): PINetChannelInfo; stdcall;
  CreateEdict: function(ForceEdictIndex: LongInt): edict_s; stdcall;
  RemoveEdict: procedure(var E: edict_t); stdcall;
  PvAllocEntPrivateData: function(CB: LongWord): Pointer; stdcall;
  FreeEntPrivateData: procedure(Entity: Pointer); stdcall;
  SaveAllocMemory: procedure(Num, Size: Cardinal); stdcall;
  SaveFreeMemory: procedure(SaveMem: Pointer); stdcall;
  EmitAmbientSound: procedure(var Entity: edict_t; const Pos: Vector; Samp: PAnsiChar; Volume: Single; SoundLevel: LongInt; Flags, Pitch: LongInt; Delay: Single = 0.0); // todo: soundlevel_t
  FadeClientVolume: procedure(var Edict: edict_t; FadePercent, FadeOutSeconds, HoldTime, FadeInSeconds: Single); stdcall;
  SentenceGroupPick: function(GroupIndex: LongInt; Name: PAnsiChar; NameBufLen: LongInt): LongInt; stdcall;
  SentenceGroupPickSequential: function(GroupIndex: LongInt; Name: PAnsiChar; NameBufLen, SentenceIndex, Reset: LongInt): LongInt; stdcall;
  SentenceIndexFromName: function(SentenceName: PAnsiChar): LongInt; stdcall;
  SentenceNameFromIndex: function(SentenceIndex: LongInt): PAnsiChar; stdcall;
  SentenceGroupIndexFromName: function(GroupName: PAnsiChar): LongInt; stdcall;
  SentenceGroupNameFromIndex: function(GroupIndex: LongInt): PAnsiChar; stdcall;
  SentenceLength: function(SentenceIndex: LongInt): Single; stdcall;
  ServerCommand: procedure(Cmd: PAnsiChar); stdcall;
  ServerExecute: procedure; stdcall;
  ClientCommand: procedure(var Edict: edict_t; Format: PAnsiChar); cdecl varargs;
  LightStyle: procedure(Style: LongInt; Val: PAnsiChar); stdcall;
  StaticDecal: procedure(const OriginInEntitySpaceL: Vector; DecalIndex, EntityIndex, ModelIndex: LongInt); stdcall;
  Message_DetermineMulticastRecipients: procedure(UserPas: Boolean; const Origin: Vector; var PlayerBits: LongWord); stdcall;
  EntityMessageBegin: function(EntIndex: LongInt; EntClass: Pointer; Reliable: Boolean): PBF_Write; stdcall; // todo: EntClass: PServerClass
  UserMessageBegin: function(var Filter: IRecipientFilter; MsgIndex, MsgSize: LongInt; MsgName: PAnsiChar): PBF_Write;
  MessageEnd: procedure; stdcall;
  ClientPrintf: procedure(const E: edict_t; Msg: PAnsiChar); stdcall;
  Con_NPrintf: procedure(Pos: LongInt; Format: PAnsiChar); cdecl varargs;
  Con_NXPrintf: procedure(const Info: con_nprint_t; Format: PAnsiChar); cdecl varargs;
  Cmd_Args: function: PAnsiChar; stdcall;
  Cmd_Argc: function: LongInt; stdcall;
  Cmd_Argv: function(Argc: LongInt): PAnsiChar; stdcall;
  SetView: procedure(var Client: edict_t; const ViewEnt: edict_t); stdcall;
  Time: function: Single; stdcall;
  CrosshairAngle: procedure(var Client: edict_t; Pitch, Yaw: Single); stdcall;
  GetGameDir: procedure(GetGameDir: PAnsiChar; MaxLength: LongInt); stdcall;
  CompareFileTime: function(FileName: PAnsiChar; FileName2: PAnsiChar; var Compare: LongInt): LongInt; stdcall;
  LockNetworkStringTables: function(Lock: Boolean): Boolean; stdcall;
  CreateFakeClient: function(NetName: PAnsiChar): edict_s; stdcall;
  GetClientConVarValue: function(ClientIndex: LongInt; Name: PAnsiChar): PAnsiChar; stdcall;
  ParseFile: function(Data, Token: PAnsiChar): PAnsiChar; stdcall;
  CopyFile: function(Source, Destination: PAnsiChar): Boolean; stdcall;
  ResetPVS: procedure(PVS: PByte); stdcall;
  AddOriginToPVS: procedure(const Origin: Vector); stdcall;
  SetAreaPortalState: procedure(PortalNumber, IsOpen: LongInt); stdcall;
  PlaybackTempEntity: procedure(var Filter: IRecipientFilter; Delay: Single; Sender: Pointer; ST: Pointer; ClassID: LongInt); stdcall; // todo: ST: SendTable
  CheckHeadnodeVisible: function(NodeNum: LongInt; VisBits: PByte): LongInt; stdcall;
  CheckAreasConnected: function(Area1, Area2: LongInt): LongInt; stdcall;
  GetArea: function(const Origin: Vector): LongInt; stdcall;
  GetAreaBits: procedure(Area: LongInt; Bits: PAnsiChar); stdcall;
  GetAreaPortalPlane: function(const ViewOrigin: Vector; PortalKey: LongInt; Plane: Pointer): Boolean; stdcall; // todo: VPlane
  ApplyTerrainMod: procedure(TerType: TerrainModType; const Params: CTerrainModParams); stdcall;
  LoadGameState: function(MapName: PAnsiChar; CreatePlayers: Boolean): Boolean; stdcall;
  LoadAdjacentEnts: procedure(OldLevel, LandmarkName: PAnsiChar); stdcall;
  ClearSaveDir: procedure; stdcall;
  GetMapEntitiesString: function: PAnsiChar; stdcall;
  TextMessageGet: function(Name: PAnsiChar): client_textmessage_s; stdcall;
  LogPrint: procedure(Msg: PAnsiChar); stdcall;
  BuildEntityClusterList: procedure(const E: edict_t; PVSInfo: Pointer); stdcall; // todo: PSVInfo: ^PVSInfo_t
  SolidMoved: procedure(const SolidEnt: edict_t; const SolidCollide: ICollideable; const PrevAbsOrigin: Vector); stdcall;
  TriggerMoved: procedure(const TriggerEnt: edict_t); stdcall;
  CreateSpatialPartition: function(const WorldMin, WorldMax: Vector): Pointer; // todo: result: ^ISpatialPartition
  DestroySpatialPartition: procedure(SpatialPartition: Pointer); stdcall; // todo: ISpatialPartition = ^ISpatialPartition
  DrawMapToScratchPad: procedure(Pad: Pointer; Flags: LongWord); stdcall; // todo: pad : ^IScratchPad3D
  GetEntityTransmitBitsForClient: function(ClientIndex: LongInt): Pointer; stdcall; // todo: result: ^array[1..MAX_EDICTS] of CBitVec
  IsPaused: function: Boolean; stdcall;
  ForceExactFile: procedure(S: PAnsiChar); stdcall;
  ForceModelBounds: procedure(S: PAnsiChar; const Mins, Maxs: Vector); stdcall;
  ClearSaveDirAfterClientLoad: procedure; stdcall;
  SetFakeClientConVarValue: procedure(var E: edict_t; Cvar, Value: PansiChar);
  InsertServerCommand: procedure(Str: PAnsiChar); stdcall;
  ForceSimpleMaterial: procedure(S: PAnsiChar); stdcall;
  IsInCommentaryMode: function: LongInt; stdcall;
  SetAreaPortalStates: procedure(PortalNumbers, IsOpen, Portals: LongInt); stdcall;
  NotifyEdictFlagsChange: procedure(Edict: LongInt); stdcall;
  GetPrevCheckTransmitInfo: function(const PlayerEdict: edict_t): Pointer; stdcall; // todo: Result = ^CCheckTransmitInfo
  GetSharedEdictChangeInfo: function: Pointer; // todo: Result = ^CSharedEdictChangeInfo
  AllowImmediateEdictReuse: procedure; stdcall;
  IsInternalBuild: function: Boolean; stdcall;
  GetChangeAccessor: function(const Edict: edict_t): Pointer; stdcall; // todo: result = ^IChangeInfoAccessor
 end;

 PIVEngineClient012 = ^IVEngineClient012;
 IVEngineClient012 = record
   GetIntersectingSurfaces: function(const Model: model_t): LongInt; stdcall;
   GetLightForPoint: function(const Pos: Vector; Clamp: Boolean): Vector; stdcall;
   TraceLineMaterialAndLighting: function(const VStart, VEnd, DiffuseLightColor, BaseColor: Vector): Pointer; // todo: result = ^IMaterial end;
   ParseFile: function(Data, Token: PAnsiChar; MaxLen: LongInt): PAnsiChar; stdcall;
   CopyFile: function(Source, Destination: PAnsiChar): Boolean; stdcall;
   GetScreenSize: procedure(var Width, Height: LongInt); stdcall;
   ServerCmd: procedure(CmdString: PAnsiChar; Reliable: Boolean); stdcall;
   ClientCmd: procedure(CmdString: PAnsiChar); stdcall;
   GetPlayerInfo: procedure(EntNum: LongInt; var Info: player_info_t); stdcall;
   GetPlayerForUserID: function(UserID: LongInt): LongInt; stdcall;
   TextMessageGet: function(Name: PAnsiChar): client_textmessage_t; stdcall;
   Con_IsVisible: function: Boolean; stdcall;
   GetLocalPlayer: function: LongInt; stdcall;
   LoadModel: function(Name: PAnsiChar; Prop: Boolean): model_s; stdcall;
   Time: function: Single; stdcall;
   GetLastTimeStamp: function: Single; stdcall;
   GetSentence: function(AudioSource: Pointer): Pointer; stdcall; // todo: AudioSource: PCAudioSource, result = ^CSentense
   GetSentenceLength: function(AudioSource: Pointer): Single; stdcall; // todo: AudioSource: PCAudioSource
   IsStreaming: function(AudioSiurce: Pointer): Single; stdcall; // todo: AudioSource: PCAudioSource
   GetViewAngles: procedure(VA: Pointer); stdcall; // todo: VA: QAngle
   SetViewAngles: procedure(VA: Pointer); stdcall; // todo: VA: QAngle
   GetMaxClients: function: LongInt; stdcall;
   Key_Event: procedure(Key: LongInt; Down: Boolean); stdcall;
   Key_LookupBinding: function(Binding: PAnsiChar): PAnsiChar; stdcall;
   StartKeyTrapMode: procedure; stdcall;
   CheckDoneKeyTrapping: function(var Buttons, Key: LongInt): Boolean; stdcall;
   IsInGame: function: Boolean; stdcall;
   IsConnected: function: Boolean; stdcall;
   IsDrawingLoadingImage: function: Boolean; stdcall;
   Con_NPrintf: procedure(Pos: LongInt; Format: PAnsiChar); cdecl varargs;
   Con_NXPrintf: procedure(const Info: con_nprint_t; Format: PAnsiChar); cdecl varargs;
   Cmd_Argc: function: LongInt; stdcall;
   Cmd_Argv: function(Argc: LongInt): PAnsiChar; stdcall;
   IsBoxVisible: function(const Mins, Maxs: Vector): LongInt; stdcall;
   IsBoxInViewCluster: function(const Mins, Maxs: Vector): LongInt; stdcall;
   CullBox: function(const Mins, Maxs: Vector): Boolean; stdcall;
   Sound_ExtraUpdate: procedure; stdcall;
   GetGameDirectory: function: PAnsiChar; stdcall;
   WorldToScreenMatrix: function: Pointer; stdcall; // todo: result = ^VMatrix
   WorldToViewMatrix: function: Pointer; stdcall; // todo: result = ^VMatrix
   GameLumpVersion: function: LongInt; stdcall;
   GameLumpSize: function: LongInt; stdcall;
   LoadGameLump: function(LumpID: LongInt; Buffer: Pointer; Size: LongInt): Boolean; stdcall;
   LevelLeafCount: function: LongInt; stdcall;
   GetBSPTreeQuery: function: PISpatialQuery; stdcall;
   LinearToGamma: procedure(var Linear, Gamma: Single); stdcall;
   LightStyleValue: function(Style: LongInt): Single; stdcall;
   ComputeDynamicLighting: procedure(const T, Normal, Color: Vector); stdcall;
   GetAmbientLightColor: procedure(const Color: Vector); stdcall;
   GetDXSupportLevel: function: LongInt; stdcall;
   SupportsHDR: function: Boolean; stdcall;
   Mat_Stub: procedure(MatSys: Pointer); stdcall; // todo: MatSys: PIMaterialSystem
   GetLevelName: function: PAnsiChar; stdcall;
   GetVoiceTweakAPI: function: Pointer; stdcall; // todo: result = (P?)PIVoiceTweak
   EngineStats_BeginFrame: procedure; stdcall;
   EngineStats_EndFrame: procedure; stdcall;
   FireEvents: procedure; stdcall;
   GetLeavesArea: function(var Leaves: Pointer; LeavesCount: LongInt): LongInt; stdcall;
   DoesBoxTouchAreaFrustum: function(const Mins, Maxs: Vector; Area: LongInt): Boolean; stdcall;
   SetHearingOrigin: procedure(const VecOrigin: Vector; const Angles: Pointer); stdcall; // todo: Angles: ^QAngle
   SentenceGroupPick: function(GroupIndex: LongInt; Name: PAnsiChar; NameBufLen: LongInt): LongInt; stdcall;
   SentenceGroupPickSequential: function(GroupIndex: LongInt; Name: PAnsiChar; NameBufLen, SentenceIndex, Reset: LongInt): LongInt; stdcall;
   SentenceIndexFromName: function(SentenceName: PAnsiChar): LongInt; stdcall;
   SentenceNameFromIndex: function(SentenceIndex: LongInt): PAnsiChar; stdcall;
   SentenceGroupIndexFromName: function(GroupName: PAnsiChar): LongInt; stdcall;
   SentenceGroupNameFromIndex: function(GroupIndex: LongInt): PAnsiChar; stdcall;
   SentenceLength: function(SentenceIndex: LongInt): Single; stdcall;
   ComputeLighting: procedure(const T, Normal: Vector; Clamp: Boolean; const Color: Vector; const BoxColors: PVector = nil); stdcall;
   ActivateOccluder: procedure(OccluderIndex: LongInt; Active: Boolean); stdcall;
   IsOccluded: function(const VecAbsMins, VecAbsMaxs: Vector): Boolean; stdcall;
   SaveAllocMemory: function(Num, Size: Cardinal): Pointer; stdcall;
   SaveFreeMemory: procedure(SaveMem: Pointer); stdcall;
   GetNetChannelInfo: function: PINetChannelInfo; stdcall;
   DebugDrawPhysCollide: procedure(Collide: Pointer; Material: Pointer; Transform: Pointer; Color: Pointer); stdcall; // todo: Collide: PCPhysCollide; Material: PIMaterial; Transform: Pmatrix3x4_t; Color: Color32
   CheckPoint: procedure(Name: PAnsiChar); stdcall;
   DrawPortals: procedure; stdcall;
   IsPlayingDemo: function: Boolean; stdcall;
   IsRecordingDemo: function: Boolean; stdcall;
   IsPlayingTimeDemo: function: Boolean; stdcall;
   IsPaused: function: Boolean; stdcall;
   IsTakingScreenshot: function: Boolean; stdcall;
   IsHLTV: function: Boolean; stdcall;
   IsLevelMainMenuBackground: function: Boolean; stdcall;
   GetMainMenuBackgroundName: procedure(Dest: PAnsiChar; DestLen: LongInt); stdcall;
   SetOcclusionParameters: procedure(Params: Pointer); // todo: Params: OcclusionParams_s
   GetUILanguage: procedure(Dest: PAnsiChar; DestLen: LongInt); stdcall;
   IsSkyboxVisibleFromPoint: function(const VecPoint: Vector): Boolean; stdcall;
   GetMapEntitiesString: function: PAnsiChar; stdcall;
   IsInEditMode: function: Boolean; stdcall;
   GetScreenAspectRatio: function: Single;
   SteamRefreshLogin: function(Password: PAnsiChar; IsSecure: Boolean): Boolean; stdcall;
   SteamProcessCall: function(var Finished: Boolean): Boolean; stdcall; // var?
   GetEngineBuildNumber: function: LongWord; stdcall;
   GetProductVersionString: function: PAnsiChar; stdcall;
   GetLastPressedEngineKey: function: LongInt; stdcall;
   GrabPreColorCorrectedFrame: procedure(X, Y, Width, Height: LongInt); stdcall;
   IsHammerRunning: function: Boolean; stdcall;
   ExecuteClientCmd: procedure(CmdString: PAnsiChar); stdcall;
   MapHasHDRLighting: function: Boolean; stdcall;
   GetAppID: function: LongInt; stdcall;
   GetLightForPointFast: function(const Pos: Vector; Clamp: Boolean): Vector; stdcall;
 end;

// IGameUI.h
type
  PVGameUI011 = ^VGameUI011;
  VGameUI011 = record
    Initialize: procedure(AppFactory: CreateInterfaceFn); stdcall;
    PostInit: procedure; stdcall;

    // connect is missing in IGameUI011
    // Connect: procedure(GameFactory: CreateInterfaceFn); stdcall;

    Start: procedure; stdcall;
    Shutdown: procedure; stdcall;
    RunFrame: procedure; stdcall;

    OnGameUIActivated: procedure; stdcall;
    OnGameUIHidden: procedure; stdcall;

    OLD_OnConnectToServer: procedure(Game: PAnsiChar; IP, Port: LongInt); stdcall;

    OnDisconnectFromServer_OLD: procedure(SteamLoginFailure: Byte; Username: PAnsiChar); stdcall;
    OnLevelLoadingStarted: procedure(LevelName: PAnsiChar; ShowProgressDialog: Boolean); stdcall;
    OnLevelLoadingFinished: procedure(Error: Boolean; FailureReason: PAnsiChar; ExtendedReason: PAnsiChar); stdcall;

    UpdateProgressBar: function(Progress: Single; StatusText: PAnsiChar): Boolean; stdcall;
    SetShowProgressText: function(Show: Boolean): Boolean; stdcall;

    SetProgressLevelName: procedure(LevelName: PAnsiChar); stdcall;

    SetLoadingBackgroundDialog: procedure(Panel: Pointer); stdcall;

    OnConnectToServer2: procedure(Game: PAnsiChar; IP, ConnectionPort, QueryPort: LongInt); stdcall;

    SetProgressOnStart: procedure; stdcall;
    OnDisconnectFromServer: procedure(SteamLoginFailure: Byte); stdcall;

    NeedConnectionProblemWaitScreen: procedure; stdcall;
    ShowPasswordUI: procedure(CurrentPW: PAnsiChar);
  end;

type
  PIGameUI011 = ^IGameUI011;
  IGameUI011 = record
    VTable: PVGameUI011;
    Data: Pointer;
  end;

const
  GAMEUI_INTERFACE_VERSION: PAnsiChar = 'GameUI011';

type
  TNetAdr = record
    ConnectionPort: Word;
    QueryPort: Word;
    IP: LongWord;
  end;

  PGameServerItem = ^TGameServerItem;
  TGameServerItem = record
    NetAdr: TNetAdr;
    Ping: Integer;
    HadSuccessfulResponse: Boolean;
    DoNotRefresh: Boolean;
    GameDir: array[0..31] of AnsiChar;
    Map: array[0..31] of AnsiChar;
    GameDescription: array[0..63] of AnsiChar;
    AppID: Integer;
    Players: Integer;
    MaxPlayers: Integer;
    BotPlayers: Integer;
    Password: Boolean;
    Secure: Boolean;
    TimeLastPlayed: LongWord;
    ServerVersion: Integer;
    ServerName: array[0..63] of AnsiChar;
    GameTags: array[0..127] of AnsiChar;
  end;

implementation

function IsSolid(SolidType: SolidType_t; nSolidFlags: LongInt): Boolean;
begin
  Result := (SolidType <> SOLID_NONE) and ((nSolidFlags and LongInt(FSOLID_NOT_SOLID)) = 0);
end;

procedure Color;
begin

end;

end.
