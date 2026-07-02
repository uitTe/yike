// cloudHelper.ets
// CloudDB / CloudFunction 封装工具
// 提供统一的数据库查询、增删改查和云函数调用入口
// ============================================================

import { cloudDatabase, cloudFunction } from '@kit.CloudFoundationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Group, GroupMember, Schedule, Role, CloudFunctionResult, CreateGroupParams, CreateGroupResult, JoinGroupParams, JoinGroupResult, DismissGroupParams, DismissGroupResult, SetAdminParams, SetAdminResult, ResetInviteCodeParams, ResetInviteCodeResult } from '../models/types'

type Params = Record<string, string | number | boolean>

const HILOG_DOMAIN = 0x0001
const TAG = '[CloudHelper]'

// ----------------------- CloudDB Zone -----------------------

/**
 * 【修改点】获取指定组的 CloudDB Zone
 * 对应 AGC 控制台创建的存储区：yk-group-zone-cecvo
 */
export function getGroupDbZone(groupId: string): cloudDatabase.DatabaseZone {
  return cloudDatabase.zone('yk-group-zone-cecvo')
}

// ... (中间的 queryAll, upsertObject, deleteObject 保持不变) ...

/**
 * 通用查询方法
 */
export async function queryAll<T extends cloudDatabase.DatabaseObject>(
  cloudDBZone: cloudDatabase.DatabaseZone,
  query: cloudDatabase.DatabaseQuery<T>
): Promise<T[]> {
  const results: T[] = await cloudDBZone.query(query)
  return results
}

/**
 * 插入或更新对象
 */
export async function upsertObject<T extends cloudDatabase.DatabaseObject>(
  cloudDBZone: cloudDatabase.DatabaseZone,
  obj: T
): Promise<void> {
  const affectedRows: number = await cloudDBZone.upsert(obj)
  hilog.info(HILOG_DOMAIN, TAG, 'upsert success, affected rows: %{public}d', affectedRows)
}

/**
 * 删除对象
 */
export async function deleteObject<T extends cloudDatabase.DatabaseObject>(
  cloudDBZone: cloudDatabase.DatabaseZone,
  obj: T
): Promise<void> {
  await cloudDBZone.delete(obj)
}


// ---------------------- 云函数调用 ----------------------

/**
 * 【修改点】创建组云函数
 */
export async function callCreateGroup(groupName: string, userId: string): Promise<CloudFunctionResult<CreateGroupResult>> {
  // 对应 AGC 云函数名: create-group
  const params: CreateGroupParams = { groupName, userId }
  const result = await callFunction<CreateGroupResult, CreateGroupParams>('create-group', params)
  return result
}

/**
 * 【修改点】加入组云函数
 */
export async function callJoinGroup(inviteCode: string, userId: string): Promise<CloudFunctionResult<JoinGroupResult>> {
  // 对应 AGC 云函数名: join-group
  const params: JoinGroupParams = { inviteCode, userId }
  const result = await callFunction<JoinGroupResult, JoinGroupParams>('join-group', params)
  return result
}

/**
 * 【修改点】解散组云函数
 */
export async function callDismissGroup(groupId: string, operatorId: string): Promise<CloudFunctionResult<DismissGroupResult>> {
  // 对应 AGC 云函数名: dismiss-group
  const params: DismissGroupParams = { groupId, operatorId }
  const result = await callFunction<DismissGroupResult, DismissGroupParams>('dismiss-group', params)
  return result
}

/**
 * 【修改点】任命/取消管理员云函数
 */
export async function callSetAdmin(
  groupId: string,
  operatorId: string,
  targetUserId: string,
  isAdmin: boolean
): Promise<CloudFunctionResult<SetAdminResult>> {
  // 对应 AGC 云函数名: set-admin
  const params: SetAdminParams = { groupId, operatorId, targetUserId, isAdmin }
  const result = await callFunction<SetAdminResult, SetAdminParams>('set-admin', params)
  return result
}

/**
 * 【修改点】重置邀请码云函数
 */
export async function callResetInviteCode(groupId: string, operatorId: string): Promise<CloudFunctionResult<ResetInviteCodeResult>> {
  // 对应 AGC 云函数名: reset-invite-code
  const params: ResetInviteCodeParams = { groupId, operatorId }
  const result = await callFunction<ResetInviteCodeResult, ResetInviteCodeParams>('reset-invite-code', params)
  return result
}

// ---------------------- 权限校验 ----------------------

/**
 * 检查用户是否有某项操作权限
 */
export function checkPermission(myRole: Role, action: 'dismiss' | 'editGroup' | 'manageInvite' | 'setAdmin' | 'removeMember' | 'editOthers'): PermissionCheck {
  switch (action) {
    case 'dismiss':
      if (myRole !== 'owner') {
        return { allowed: false, reason: '仅创建者可解散组' }
      }
      break
    case 'editGroup':
    case 'manageInvite':
      if (myRole !== 'owner' && myRole !== 'admin') {
        return { allowed: false, reason: '仅创建者和管理员可执行此操作' }
      }
      break
    case 'setAdmin':
      if (myRole !== 'owner') {
        return { allowed: false, reason: '仅创建者可任命管理员' }
      }
      break
    case 'removeMember':
      // 根据你的云函数逻辑，owner 和 admin 都可以移除成员
      if (myRole === 'owner' || myRole === 'admin') return { allowed: true }
      return { allowed: false, reason: '仅创建者和管理员可移除成员' }
    case 'editOthers':
      if (myRole === 'owner' || myRole === 'admin') return { allowed: true }
      return { allowed: false, reason: '无权限编辑他人数据' }
  }
  return { allowed: true }
}

/**
 * 权限检查结果包装器
 */
export function ensurePermission(check: PermissionCheck): void {
  if (!check.allowed) {
    hilog.warn(HILOG_DOMAIN, TAG, 'permission denied: %{public}s', check.reason ?? 'unknown')
    throw new Error(check.reason ?? '权限不足')
  }
}

// ---------------------- 邀请码工具 ----------------------

export function formatInviteCode(code: string): string {
  if (code.length <= 6) return code
  return `${code.substring(0, 3)} ${code.substring(3)}`
}

export function isInviteCodeExpired(expireTime?: string): boolean {
  if (!expireTime) return false
  return new Date(expireTime).getTime() < Date.now()
}

// ---------------------- 内部辅助 ----------------------

async function callFunction<T, P extends Object>(
  name: string,
  params: P // 使用泛型参数，兼容各种参数类型
): Promise<CloudFunctionResult<T>> {
  return new Promise((resolve, reject) => {
    cloudFunction.call({
      name: name,
      data: params
    }).then((result) => {
      // 根据 HarmonyOS SDK，cloudFunction.call 返回的 FunctionResult 只有一个 result 属性
      // result.result 可以是字符串或对象，需要解析为 CloudFunctionResult
      let cloudResult: CloudFunctionResult<T>;
      
      if (typeof result.result === 'string') {
        try {
          cloudResult = JSON.parse(result.result) as CloudFunctionResult<T>;
        } catch (e) {
          // 如果解析失败，返回错误结果
          hilog.error(HILOG_DOMAIN, TAG, 'Failed to parse cloud function result: %{public}s', result.result);
          cloudResult = { code: 500, message: '云函数返回数据格式错误' };
        }
      } else if (result.result && typeof result.result === 'object') {
        // 如果 result.result 已经是对象，直接使用
        const resObj = result.result as Record<string, string | number | boolean | object | null>;
        cloudResult = {
          code: (resObj.code as number) ?? 0,
          message: (resObj.message as string) ?? '',
          data: resObj.data as T
        };
      } else {
        // 未知格式
        hilog.error(HILOG_DOMAIN, TAG, 'Unknown cloud function result format: %{public}s', JSON.stringify(result));
        cloudResult = { code: 500, message: '云函数返回格式未知' };
      }
      
      resolve(cloudResult);
    }).catch((err: BusinessError) => {
      hilog.error(HILOG_DOMAIN, TAG, 'cloud function [%{public}s] call failed: %{public}s', name, JSON.stringify(err))
      // 这里把 reject 改成了 resolve 错误对象，防止 UI 崩溃，业务层可以根据 code 判断
      resolve({ code: err.code ?? 500, message: '云函数调用失败' })
    })
  })
}

interface PermissionCheck {
  allowed: boolean
  reason?: string
}