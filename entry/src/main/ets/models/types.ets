// ============================================================
// types.ets
// 全局类型定义 — 角色、组、成员、排班等业务模型
// 与 docs/开发流程梳理.md 中的 CloudDB 表结构一一对应
// ============================================================

/** 组内角色 */
export type Role = 'owner' | 'admin' | 'member'

/** 班次类型 */
export type Shift = '早' | '晚' | '休'

// -------------------------- 组 --------------------------

/**
 * 组信息
 * 对应 CloudDB Group 对象类型
 */
export interface Group {
  id: string                       // 组ID
  name: string                     // 组名称（如：我家）
  creatorId: string                // 创建者ID (Owner)
  inviteCode: string               // 6位邀请码
  inviteCodeExpireTime?: string    // 邀请码过期时间 (ISO字符串)
  enabledFeatures: string[]        // 开启的功能列表 ['schedule']
  featurePermissions?: string      // 功能权限配置 JSON 字符串
  createTime: string               // 创建时间 ISO字符串
  myRole?: Role                    // 当前用户在组内的角色
}

// ----------------------- 组成员 -----------------------

/**
 * 组成员关系
 * 对应 CloudDB GroupMember 对象类型
 */
export interface GroupMember {
  id: string                       // 关系ID
  groupId: string                  // 组ID
  userId: string                   // 用户ID
  nicknameInGroup?: string         // 组内昵称
  role: Role                       // owner / admin / member
  customPermissions?: string[]     // 自定义权限
  joinTime: string                 // 加入时间 ISO字符串
}

// ------------------------ 排班 ------------------------

/**
 * 排班记录
 * 对应 CloudDB Schedule 对象类型
 */
export interface Schedule {
  id: string                       // 记录ID
  groupId: string                  // 所属组ID
  userId: string                   // 用户ID
  date: string                     // 日期 YYYY-MM-DD
  shift: Shift                     // 早 / 晚 / 休
  remark?: string                  // 备注
  updateTime: string               // 更新时间 ISO字符串
}

// ------------------------ 用户 ------------------------

/**
 * 用户信息
 * 对应 CloudDB User 对象类型
 */
export interface User {
  id: string                       // 华为 UnionID
  nickname?: string                // 昵称
  avatarUrl?: string               // 头像URL
  phoneMask?: string               // 脱敏手机号
  settings?: string                // 全局设置 JSON
  createTime: string               // 注册时间 ISO字符串
}

// --------------------- 工具类型 ---------------------

/** 权限检查结果 */
export interface PermissionCheck {
  allowed: boolean
  reason?: string
}

/** 云函数调用结果 */
export interface CloudFunctionResult<T = Record<string, string | number>> {
  code: number
  message: string
  data?: T
}

// 云函数参数和返回值类型
export interface CreateGroupParams {
  groupName: string;
  userId: string;
}

export interface CreateGroupResult {
  groupId: string;
}

export interface JoinGroupParams {
  inviteCode: string;
  userId: string;
}

export interface JoinGroupResult {
  // 空对象
}

export interface DismissGroupParams {
  groupId: string;
  operatorId: string;
}

export interface DismissGroupResult {
  // 空对象
}

export interface SetAdminParams {
  groupId: string;
  operatorId: string;
  targetUserId: string;
  isAdmin: boolean;
}

export interface SetAdminResult {
  // 空对象
}

export interface ResetInviteCodeParams {
  groupId: string;
  operatorId: string;
}

export interface ResetInviteCodeResult {
  inviteCode: string;
}

// 功能权限配置类型
export interface FeaturePermission {
  member: string;
  admin: string;
  owner: string;
}

export interface FeaturePermissions {
  schedule: FeaturePermission;
}